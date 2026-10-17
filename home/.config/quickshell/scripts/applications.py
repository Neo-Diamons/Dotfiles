#!/usr/bin/env python3
"""Desktop applications as JSON for the launcher."""

import argparse
import json
import sys
from pathlib import Path

from lib.icons import find_icon_file, get_icon_index
from lib.log import print_warning

HOME = Path.home()

APP_DIRS = [
    HOME / ".local/share/applications",
    Path("/var/lib/flatpak/exports/share/applications"),
    Path("/usr/local/share/applications"),
    Path("/usr/share/applications"),
]

VALID_TYPES = {"Application", "Link", "Directory"}
BOOLEAN_KEYS = {
    "NoDisplay",
    "Hidden",
    "Terminal",
    "DBusActivatable",
    "StartupNotify",
    "PrefersNonDefaultGPU",
    "SingleMainWindow",
}


def process_desktop(file_path: Path) -> dict:
    desktop: dict[str, dict] = {}
    current_section = None

    with open(file_path, "r", encoding="utf-8") as file:
        for line in file:
            line = line.strip()
            if not line or line.startswith("#"):
                continue

            if line.startswith("[") and line.endswith("]"):
                current_section = line[1:-1].strip()
                desktop[current_section] = {}
                continue

            if "=" in line and current_section is not None:
                key, value = line.split("=", 1)
                desktop[current_section][key.strip()] = value

    if "Desktop Entry" in desktop:
        entry = desktop["Desktop Entry"]
        if "Type" not in entry or "Name" not in entry:
            raise KeyError(
                f"[{file_path}] [Desktop Entry] missing required key(s): must contain both 'Type' and 'Name'."
            )

        entry_type = entry["Type"]
        if entry_type not in VALID_TYPES:
            raise ValueError(
                f"[{file_path}] [Desktop Entry] Invalid Type {entry_type!r}. Must be one of: {', '.join(sorted(VALID_TYPES))}"
            )
        if entry_type == "Application" and "Exec" not in entry:
            raise KeyError(
                f"[{file_path}] [Desktop Entry] Missing required key 'Exec' for Type='Application'"
            )
        if entry_type == "Link" and "URL" not in entry:
            raise ValueError(
                f"[{file_path}] [Desktop Entry] Missing required key 'URL' for Type='Link'"
            )

    for section, entries in desktop.items():
        for key, val in entries.items():
            if key not in BOOLEAN_KEYS:
                continue
            match val:
                case "true":
                    desktop[section][key] = True
                case "false":
                    desktop[section][key] = False
                case other:
                    raise ValueError(
                        f"[{file_path}] [{section}] Invalid boolean for '{key}': expected 'true' or 'false', got {other!r}"
                    )

    return desktop


def get_applications() -> list[dict]:
    seen_desktop_ids: set[str] = set()
    applications: list[dict] = []

    for app_dir in APP_DIRS:
        if not app_dir.is_dir():
            continue

        for filepath in app_dir.glob("**/*.desktop"):
            desktop_id = str(filepath.relative_to(app_dir)).replace("/", "-")
            if desktop_id in seen_desktop_ids:
                continue
            seen_desktop_ids.add(desktop_id)

            try:
                desktop = process_desktop(filepath)
            except (KeyError, ValueError) as err:
                print_warning(desktop_id, err)
                continue

            entry = desktop.get("Desktop Entry", {})
            if not entry:
                continue

            if entry.get("Hidden") is True or entry.get("NoDisplay") is True:
                continue

            applications.append(
                {
                    "name": entry.get("Name"),
                    "exec": entry.get("Exec"),
                    "icon": entry.get("Icon", "application-x-executable"),
                    "terminal": entry.get("Terminal", False),
                }
            )

    return sorted(applications, key=lambda app: (app["name"] or "").casefold())


def cmd_list(args) -> None:
    applications = get_applications()

    if not args.no_icons:
        index = get_icon_index()
        for app in applications:
            app["iconFile"] = find_icon_file(index, app["icon"], app["name"] or "")

    print(json.dumps(applications))


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="applications",
        description="List desktop applications as JSON.",
    )
    sub = parser.add_subparsers(dest="command", metavar="<command>")

    p_list = sub.add_parser("list", help="list applications as JSON")
    p_list.add_argument("--no-icons", action="store_true", help="skip icon lookup")
    p_list.set_defaults(func=cmd_list)

    args = parser.parse_args()

    if not getattr(args, "func", None):
        parser.print_help()
        sys.exit(0)

    args.func(args)


if __name__ == "__main__":
    main()
