#!/usr/bin/env python3
"""Icon lookup and index cache commands."""

import argparse
import json
import sys

from lib.icons import (
    ICON_CACHE,
    get_icon_index,
    get_icon_theme,
    get_theme_chain,
    lookup_icon_file,
)


def cmd_lookup(args) -> None:
    print(json.dumps({"iconFile": lookup_icon_file(get_icon_index(), args.names)}))


def cmd_info(_args) -> None:
    theme = get_icon_theme()
    print(
        json.dumps(
            {
                "theme": theme,
                "chain": get_theme_chain(theme),
                "icons": len(get_icon_index()),
                "cache": str(ICON_CACHE),
            }
        )
    )


def cmd_clear_cache(_args) -> None:
    ICON_CACHE.unlink(missing_ok=True)
    print(json.dumps({"ok": True}))


def main() -> None:
    parser = argparse.ArgumentParser(
        prog="icons",
        description="Resolve icons from the user's icon theme.",
    )
    sub = parser.add_subparsers(dest="command", metavar="<command>")

    p_lookup = sub.add_parser(
        "lookup", help="resolve one icon from names tried in order, as JSON"
    )
    p_lookup.add_argument("names", nargs="*", help="icon names, ids or titles")
    p_lookup.set_defaults(func=cmd_lookup)

    sub.add_parser(
        "info", help="show the detected icon theme and index size"
    ).set_defaults(func=cmd_info)
    sub.add_parser("clear-cache", help="delete the icon index cache").set_defaults(
        func=cmd_clear_cache
    )

    args = parser.parse_args()

    if not getattr(args, "func", None):
        parser.print_help()
        sys.exit(0)

    args.func(args)


if __name__ == "__main__":
    main()
