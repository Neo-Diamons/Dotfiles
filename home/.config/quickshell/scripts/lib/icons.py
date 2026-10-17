"""Icon theme lookup: resolves icon names to files of the user's theme.

The theme's icons are indexed once and cached in ICON_CACHE; the index is
rebuilt only when the theme or its folders change.
"""

import configparser
import json
import os
import re
import subprocess
from pathlib import Path

HOME = Path.home()

ICON_DIRS = [
    HOME / ".local/share/icons",
    HOME / ".icons",
    Path("/usr/local/share/icons"),
    Path("/usr/share/icons"),
    Path("/var/lib/flatpak/exports/share/icons"),
    HOME / ".local/share/flatpak/exports/share/icons",
]
PIXMAPS_DIR = Path("/usr/share/pixmaps")

# Set LAUNCHER_ICON_THEME to override the theme detected from GTK
ICON_THEME_OVERRIDE = os.environ.get("LAUNCHER_ICON_THEME", "")
ICON_EXTENSIONS = {".svg", ".png"}
ICON_CACHE = HOME / ".cache/quickshell/icon-index.json"


def get_icon_theme() -> str:
    """Return the icon theme name: override, then GTK, then hicolor."""
    if ICON_THEME_OVERRIDE:
        return ICON_THEME_OVERRIDE

    try:
        result = subprocess.run(
            ["gsettings", "get", "org.gnome.desktop.interface", "icon-theme"],
            capture_output=True,
            text=True,
            timeout=2,
            check=True,
        )
        name = result.stdout.strip().strip("'\"")
        if name:
            return name
    except (OSError, subprocess.SubprocessError):
        pass

    parser = configparser.ConfigParser(strict=False, interpolation=None)
    parser.read(HOME / ".config/gtk-3.0/settings.ini")
    return parser.get("Settings", "gtk-icon-theme-name", fallback="hicolor")


def get_theme_chain(theme: str) -> list[str]:
    """Return the theme followed by everything it inherits, ending in hicolor."""
    chain: list[str] = []
    queue = [theme]

    while queue:
        name = queue.pop(0)
        if name in chain:
            continue
        chain.append(name)

        for icon_dir in ICON_DIRS:
            index_file = icon_dir / name / "index.theme"
            if not index_file.is_file():
                continue
            parser = configparser.ConfigParser(strict=False, interpolation=None)
            try:
                parser.read(index_file)
                inherits = parser.get("Icon Theme", "Inherits", fallback="")
            except configparser.Error:
                inherits = ""
            queue += [item.strip() for item in inherits.split(",") if item.strip()]
            break

    if "hicolor" not in chain:
        chain.append("hicolor")
    return chain


def icon_rank(path: Path) -> tuple:
    """Sort key, lower is better: apps context, scalable, biggest size, svg."""
    parts = path.parts
    context = 0 if "apps" in parts else 1
    ext = 0 if path.suffix == ".svg" else 1

    if "scalable" in parts:
        return (context, 0, 0, ext)

    sizes = [
        int(match.group(1))
        for part in parts
        if (match := re.fullmatch(r"(\d+)(?:x\d+)?", part))
    ]
    if sizes:
        return (context, 1, -max(sizes), ext)
    return (context, 2, 0, ext)


def get_cache_key(theme: str, roots: list[Path]) -> str:
    """Change detector: theme name + newest folder mtime, three levels deep."""
    latest = 0.0
    for root in roots:
        stack = [(root, 0)]
        while stack:
            folder, depth = stack.pop()
            try:
                latest = max(latest, folder.stat().st_mtime)
                if depth < 3:
                    stack += [
                        (Path(e.path), depth + 1)
                        for e in os.scandir(folder)
                        if e.is_dir()
                    ]
            except OSError:
                continue
    return f"{theme}:{latest}"


def build_icon_index(chain: list[str]) -> dict[str, str]:
    """Map icon name -> best file, searching themes in inheritance order."""
    index: dict[str, str] = {}

    for theme in chain:
        best: dict[str, tuple] = {}
        found: dict[str, str] = {}

        for icon_dir in ICON_DIRS:
            root = icon_dir / theme
            if not root.is_dir():
                continue
            for dirpath, _, files in os.walk(root):
                for filename in files:
                    path = Path(dirpath) / filename
                    if path.suffix not in ICON_EXTENSIONS or path.stem.endswith(
                        "-symbolic"
                    ):
                        continue
                    rank = icon_rank(path)
                    if path.stem not in best or rank < best[path.stem]:
                        best[path.stem] = rank
                        found[path.stem] = str(path)

        for name, path in found.items():
            index.setdefault(name, path)

    if PIXMAPS_DIR.is_dir():
        for path in PIXMAPS_DIR.iterdir():
            if path.suffix in ICON_EXTENSIONS:
                index.setdefault(path.stem, str(path))

    return index


def get_icon_index() -> dict[str, str]:
    theme = get_icon_theme()
    chain = get_theme_chain(theme)
    roots = [d / t for t in chain for d in ICON_DIRS if (d / t).is_dir()]
    key = get_cache_key(theme, roots)

    try:
        cached = json.loads(ICON_CACHE.read_text())
        if cached.get("key") == key:
            return cached["index"]
    except (OSError, ValueError, KeyError):
        pass

    index = build_icon_index(chain)

    try:
        ICON_CACHE.parent.mkdir(parents=True, exist_ok=True)
        ICON_CACHE.write_text(json.dumps({"key": key, "index": index}))
    except OSError:
        pass
    return index


def find_icon_file(index: dict[str, str], icon: str, name: str) -> str:
    if not icon or icon.startswith("/"):
        return ""

    last = icon.split(".")[-1]  # com.discordapp.Discord -> Discord
    candidates = (
        icon,
        icon.lower(),
        last,
        last.lower(),
        name,
        name.lower(),
        name.lower().replace(" ", "-"),
    )
    for candidate in candidates:
        if candidate and candidate in index:
            return index[candidate]
    return ""


def lookup_icon_file(index: dict[str, str], names: list[str]) -> str:
    """Best file for loose names (tray id, title, icon name...), tried in order.

    Exact forms of every name come first, then each name's first word
    (discord_status_icon_1 -> discord, steam_tray_mono -> steam).
    """
    exact: list[str] = []
    loose: list[str] = []
    for name in filter(None, names):
        last = name.split(".")[-1]
        exact += [
            name,
            name.lower(),
            last,
            last.lower(),
            name.lower().replace(" ", "-"),
        ]
        loose.append(re.split(r"[_\-\s]", last.lower())[0])

    for candidate in exact + loose:
        if candidate and candidate in index:
            return index[candidate]
    return ""
