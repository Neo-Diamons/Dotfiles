#!/usr/bin/env python3

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

IMAGE_EXTENSIONS = {
    ".png",
    ".jpg",
    ".jpeg",
    ".webp",
    ".jxl",
    ".gif",
    ".bmp",
    ".tiff",
    ".avif",
}


COVER_DIR = (
    Path(os.environ.get("XDG_CACHE_HOME") or Path.home() / ".cache")
    / "quickshell"
    / "wallpapers"
)


def get_current_wallpapers() -> dict[str, Path]:
    result = subprocess.run(
        ["hyprctl", "hyprpaper", "listactive"],
        capture_output=True,
        text=True,
        check=True,
    )

    wallpapers = {}
    for line in result.stdout.strip().splitlines():
        monitor, path = line.split(": ", 1)
        wallpapers[monitor.strip()] = Path(path.strip())
    return wallpapers


def get_current_wallpaper() -> Path | None:
    current_wallpapers = get_current_wallpapers()
    monitors = list(current_wallpapers.keys())

    if len(monitors) == 0:
        return None
    else:
        return current_wallpapers[monitors[0]]


def get_wallpapers(folder: Path) -> list[Path]:
    return sorted(
        path
        for path in folder.rglob("*")
        if path.is_file() and path.suffix.lower() in IMAGE_EXTENSIONS
    )


def cover_path(wallpaper: Path, width: int, height: int) -> Path:
    # Keyed by content identity and size: an edited wallpaper gets a new cover
    stat = wallpaper.stat()
    key = f"{wallpaper}|{stat.st_mtime_ns}|{stat.st_size}|{width}x{height}"
    return COVER_DIR / f"{hashlib.sha1(key.encode()).hexdigest()[:16]}.jpg"


def make_cover(wallpaper: Path, cover: Path, width: int, height: int) -> bool:
    part = cover.with_name(f"{cover.name}.{os.getpid()}.part")
    result = subprocess.run(
        [
            "nice",
            "-n",
            "10",
            "magick",
            f"{wallpaper}[0]",
            "-resize",
            f"{width}x{height}^",
            "-gravity",
            "center",
            "-extent",
            f"{width}x{height}",
            "-strip",
            "-quality",
            "88",
            f"jpg:{part}",
        ],
        capture_output=True,
    )
    if result.returncode != 0:
        part.unlink(missing_ok=True)
        return False
    part.replace(cover)
    return True


def parse_size(size: str) -> tuple[int, int]:
    width, height = (int(n) for n in size.lower().split("x"))
    return width, height


def get_covers(wallpapers: list[Path], size: str) -> tuple[list[Path], int]:
    """Cover of each wallpaper if it is already built, else the original, and
    the number of covers still to build. Never builds anything: it must be fast."""
    if shutil.which("magick") is None:
        return wallpapers, 0

    width, height = parse_size(size)
    covers = [cover_path(w, width, height) for w in wallpapers]
    ready = [c.exists() for c in covers]
    return [c if ok else w for w, c, ok in zip(wallpapers, covers, ready)], ready.count(False)


def build_covers(wallpapers: list[Path], size: str) -> None:
    """Build the missing covers, already cropped to the card, and drop the stale ones."""
    if shutil.which("magick") is None:
        return

    width, height = parse_size(size)
    COVER_DIR.mkdir(parents=True, exist_ok=True)
    covers = [cover_path(w, width, height) for w in wallpapers]

    missing = [(w, c) for w, c in zip(wallpapers, covers) if not c.exists()]
    with ThreadPoolExecutor(max_workers=os.cpu_count() or 1) as pool:
        list(pool.map(lambda wc: make_cover(*wc, width, height), missing))

    for old in COVER_DIR.glob("*.jpg"):  # covers of removed or edited wallpapers
        if old not in covers:
            old.unlink(missing_ok=True)


def cmd_list(args) -> None:
    wallpapers = get_wallpapers(Path(args.folder).expanduser())
    covers, missing = get_covers(wallpapers, args.covers) if args.covers else (wallpapers, 0)
    current = get_current_wallpaper()

    try:
        current_index = wallpapers.index(current)
    except ValueError:  # no wallpaper set, or it is outside the folder
        current_index = -1

    print(
        json.dumps(
            {
                "wallpapers": wallpapers,
                "covers": covers,
                "missingCovers": missing,
                "currentIndex": current_index,
            },
            default=str,
        )
    )


def cmd_covers(args) -> None:
    build_covers(get_wallpapers(Path(args.folder).expanduser()), args.size)


def cmd_current(_args) -> None:
    print(json.dumps({"current": get_current_wallpaper()}))


def cmd_set(args) -> None:
    path = str(Path(args.path).expanduser().resolve())
    if not Path(path).is_file():
        print(json.dumps({"ok": False, "error": f"not found: {path}"}))
        sys.exit(1)

    monitor = args.monitor or ""  # empty = all monitors
    result = subprocess.run(
        ["hyprctl", "hyprpaper", "wallpaper", f"{monitor},{path}"],
        capture_output=True,
        text=True,
        check=True,
    )
    if result.returncode != 0:
        print(json.dumps({"ok": False, "error": result.stderr.strip()}))
        sys.exit(1)

    if not args.no_theme:
        subprocess.run(
            ["wallust", "run", "-s", path],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=True,
        )

    print(json.dumps({"ok": True, "current": path}))


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="wallpapers",
        description="List, inspect and set wallpapers (hyprpaper + wallust).",
    )
    sub = parser.add_subparsers(dest="command", metavar="<command>")

    p_list = sub.add_parser("list", help="list wallpapers and the current index")
    p_list.add_argument("folder", help="wallpaper folder")
    p_list.add_argument(
        "--covers",
        metavar="WxH",
        help="also return the covers already built for this size (default: originals)",
    )
    p_list.set_defaults(func=cmd_list)
    p_covers = sub.add_parser("covers", help="build the missing covers (slow, run in background)")
    p_covers.add_argument("folder", help="wallpaper folder")
    p_covers.add_argument("size", metavar="WxH", help="cover size")
    p_covers.set_defaults(func=cmd_covers)

    sub.add_parser("current", help="print the current wallpaper").set_defaults(
        func=cmd_current
    )

    p_set = sub.add_parser("set", help="set a wallpaper")
    p_set.add_argument("path", help="image path")
    p_set.add_argument("-m", "--monitor", help="monitor name (default: all)")
    p_set.add_argument("--no-theme", action="store_true", help="skip wallust")
    p_set.set_defaults(func=cmd_set)

    args = parser.parse_args()

    if not getattr(args, "func", None):
        parser.print_help()
        sys.exit(0)

    args.func(args)


if __name__ == "__main__":
    main()
