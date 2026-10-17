#!/usr/bin/env python3
"""Battery saver for Hyprland: no blur, shadows or animations, 60 Hz, no CPU turbo,
opaque terminals and the power-saver profile while active.

State lives in ~/.local/state/powersave/: `mode` (auto | on | off) and `active`
(1 | 0), which hypr/conf/powersave.lua reads on every Hyprland reload.
Every command prints the state as JSON; `watch` prints it again on each change.
`refresh` is run by powersave.lua after each reload to cap the refresh rate to 60 Hz.
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path

from lib.log import print_warning

STATE_DIR = (
    Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "powersave"
)
MODE_FILE = STATE_DIR / "mode"
ACTIVE_FILE = STATE_DIR / "active"
POWER_SUPPLY = Path("/sys/class/power_supply")
INTEL_NO_TURBO = Path("/sys/devices/system/cpu/intel_pstate/no_turbo")
CPU_BOOST = Path("/sys/devices/system/cpu/cpufreq/boost")
MODES = ("auto", "on", "off")


def read(path: Path, default: str = "") -> str:
    try:
        return path.read_text().strip()
    except OSError:
        return default


def has_battery() -> bool:
    return any(
        read(p / "type") == "Battery" and read(p / "scope") != "Device"
        for p in POWER_SUPPLY.iterdir()
    )


def on_battery() -> bool:
    plugged = any(
        read(p / "type") != "Battery" and read(p / "online") == "1"
        for p in POWER_SUPPLY.iterdir()
    )
    return has_battery() and not plugged


def get_mode() -> str:
    mode = read(MODE_FILE, "auto")
    return mode if mode in MODES else "auto"


def wanted_active(mode: str) -> bool:
    if mode == "auto":
        return on_battery()
    return mode == "on"


def set_turbo(enabled: bool) -> None:
    """Needs write access to the file (see system/ tmpfiles rule); AMD has `boost`."""
    for path, value in (
        (INTEL_NO_TURBO, "0" if enabled else "1"),
        (CPU_BOOST, "1" if enabled else "0"),
    ):
        if path.exists() and read(path) != value:
            try:
                path.write_text(value)
            except OSError as err:
                print_warning(__file__, Exception(f"{path}: {err.strerror}"))


def set_profile(active: bool) -> None:
    """power-profiles-daemon: power-saver while active, back to balanced afterwards."""
    current = subprocess.run(
        ["powerprofilesctl", "get"], capture_output=True, text=True
    ).stdout.strip()
    if active and current != "power-saver":
        subprocess.run(["powerprofilesctl", "set", "power-saver"], capture_output=True)
    elif not active and current == "power-saver":
        subprocess.run(["powerprofilesctl", "set", "balanced"], capture_output=True)


def set_terminals(active: bool) -> None:
    """foot colour themes: light is the opaque copy of the palette (SIGUSR2), dark the normal one."""
    subprocess.run(
        ["pkill", "-u", str(os.getuid()), f"-USR{2 if active else 1}", "-x", "foot"],
        capture_output=True,
    )


def apply(mode: str) -> dict:
    """Write the active flag, reload Hyprland when it changed, and set the CPU."""
    active = wanted_active(mode)
    # not only on change: turbo and the profile are reset by a reboot
    set_turbo(not active)
    set_terminals(active)
    if shutil.which("powerprofilesctl"):
        set_profile(active)
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    if read(ACTIVE_FILE, "0") != ("1" if active else "0"):
        ACTIVE_FILE.write_text("1" if active else "0")
        subprocess.run(["hyprctl", "reload"], capture_output=True, check=True)
    return {
        "battery": has_battery(),
        "onBattery": on_battery(),
        "mode": mode,
        "active": active,
    }


def capped_modes(monitors: list[dict], max_hz: float = 60.5) -> dict[str, str]:
    """Highest refresh rate <= max_hz at each monitor's current resolution."""
    capped = {}
    for monitor in monitors:
        prefix = f"{monitor['width']}x{monitor['height']}@"
        rates = [
            float(mode[len(prefix) : -2])
            for mode in monitor["availableModes"]
            if mode.startswith(prefix) and float(mode[len(prefix) : -2]) <= max_hz
        ]
        if rates:
            capped[monitor["name"]] = f"{prefix}{max(rates)}"
    return capped


def cmd_refresh(args) -> None:
    """Cap every monitor to ~60 Hz; a Hyprland reload restores the configured mode."""
    time.sleep(args.delay)  # the reload that started us has to finish first
    result = subprocess.run(
        ["hyprctl", "monitors", "-j"], capture_output=True, text=True, check=True
    )
    monitors = json.loads(result.stdout)
    modes = capped_modes(monitors)
    for monitor in monitors:
        mode = modes.get(monitor["name"])
        if mode is None:
            continue
        lua = (
            f'hl.monitor({{ output = "{monitor["name"]}", mode = "{mode}", '
            f'position = "{monitor["x"]}x{monitor["y"]}", scale = "{monitor["scale"]}" }})'
        )
        if args.dry_run:
            print(lua)
        else:
            subprocess.run(["hyprctl", "eval", lua], capture_output=True)


def cmd_status(_args) -> None:
    print(json.dumps(apply(get_mode())))


def cmd_mode(args) -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    MODE_FILE.write_text(args.mode)
    print(json.dumps(apply(args.mode)))


def cmd_toggle(_args) -> None:
    mode = "off" if wanted_active(get_mode()) else "on"
    cmd_mode(argparse.Namespace(mode=mode))


def cmd_watch(_args) -> None:
    state = apply(get_mode())
    print(json.dumps(state), flush=True)
    if not state["battery"]:
        return

    udev = subprocess.Popen(
        ["udevadm", "monitor", "--udev", "--subsystem-match=power_supply"],
        stdout=subprocess.PIPE,
        text=True,
    )
    for _line in udev.stdout or []:
        time.sleep(1)
        new_state = apply(get_mode())
        if new_state != state:
            state = new_state
            print(json.dumps(state), flush=True)


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="powersave", description="Hyprland battery saver mode."
    )
    sub = parser.add_subparsers(dest="command", metavar="<command>")

    sub.add_parser("status", help="apply and print the state").set_defaults(
        func=cmd_status
    )
    p_mode = sub.add_parser("mode", help="set the mode")
    p_mode.add_argument("mode", choices=MODES)
    p_mode.set_defaults(func=cmd_mode)
    sub.add_parser("toggle", help="switch between forced on and off").set_defaults(
        func=cmd_toggle
    )
    p_refresh = sub.add_parser("refresh", help="cap monitors to 60 Hz")
    p_refresh.add_argument("--delay", type=float, default=1.0, help="seconds to wait")
    p_refresh.add_argument("--dry-run", action="store_true", help="print, don't apply")
    p_refresh.set_defaults(func=cmd_refresh)
    sub.add_parser("watch", help="follow the power source").set_defaults(func=cmd_watch)

    args = parser.parse_args()

    if not getattr(args, "func", None):
        parser.print_help()
        sys.exit(0)

    args.func(args)


if __name__ == "__main__":
    main()
