#!/usr/bin/env python3
"""Make wallust-generated foot colours readable.

Raises (or, on a light background, lowers) the lightness of regular1-6 and
bright1-6 until each reaches a minimum WCAG contrast ratio against the
background of ITS OWN section, keeping hue and saturation. Colours that already
pass are left untouched, and the file is only rewritten when something changed.

Usage:
    fix-contrast.py [FILE]            fix in place (default ~/.config/foot/colors.ini)
    fix-contrast.py --check [FILE]    only report; exit 1 if any colour is too low
    fix-contrast.py --regular 4.5 --bright 6 [FILE]
"""

import argparse
import colorsys
import os
import re
import shutil
import sys

SECTION = re.compile(r"^\[(?P<name>[^\]]+)\]\s*$")
BG = re.compile(r"^background=(?P<hash>#?)(?P<col>[0-9a-fA-F]{6})\s*$")
KEY = re.compile(
    r"^(?P<kind>regular|bright)(?P<n>[1-6])=(?P<hash>#?)(?P<col>[0-9a-fA-F]{6})\s*$"
)
MIN_SATURATION = 0.3


def to_rgb(hexc):
    return [int(hexc[i : i + 2], 16) / 255 for i in (0, 2, 4)]


def to_hex(rgb):
    return "".join(f"{round(v * 255):02x}" for v in rgb)


def lum(hexc):
    c = [
        x / 12.92 if x <= 0.03928 else ((x + 0.055) / 1.055) ** 2.4
        for x in to_rgb(hexc)
    ]
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]


def ratio(a, b):
    hi, lo = sorted((lum(a), lum(b)), reverse=True)
    return (hi + 0.05) / (lo + 0.05)


def fix(hexc, bg, target):
    """Smallest lightness change (hue/saturation kept) that reaches `target`."""
    if ratio(hexc, bg) >= target:
        return hexc
    h, l, s = colorsys.rgb_to_hls(*to_rgb(hexc))
    s = max(s, MIN_SATURATION)

    def at(x):
        return to_hex(colorsys.hls_to_rgb(h, x, s))

    lighten = lum(bg) < 0.179
    lo, hi = (l, 1.0) if lighten else (0.0, l)
    if ratio(at(1.0 if lighten else 0.0), bg) < target:
        return at(1.0 if lighten else 0.0)
    for _ in range(24):
        mid = (lo + hi) / 2
        ok = ratio(at(mid), bg) >= target
        if lighten:
            hi, lo = (mid, lo) if ok else (hi, mid)
        else:
            lo, hi = (mid, hi) if ok else (lo, mid)
    return at(hi if lighten else lo)


def section_backgrounds(lines):
    bgs, cur = {}, None
    for ln in lines:
        if m := SECTION.match(ln):
            cur = m["name"]
        elif m := BG.match(ln):
            bgs[cur] = m["col"]
    return bgs


def process(lines, targets):
    """Return (new_lines, problems). A problem is (section, key, old, new, ratio_old)."""
    bgs = section_backgrounds(lines)
    out, problems, cur = [], [], None
    for ln in lines:
        if m := SECTION.match(ln):
            cur = m["name"]
        elif (m := KEY.match(ln)) and cur in bgs:
            old = m["col"]
            new = fix(old, bgs[cur], targets[m["kind"]])
            if new.lower() != old.lower():
                key = f"{m['kind']}{m['n']}"
                problems.append(
                    (cur, key, old, new, ratio(old, bgs[cur]), ratio(new, bgs[cur]))
                )
                ln = f"{key}={m['hash']}{new}"
        out.append(ln)
    return out, problems


def main():
    ap = argparse.ArgumentParser(
        description="Raise wallust foot colours to a minimum contrast against their background."
    )
    ap.add_argument("file", nargs="?", default="~/.config/foot/colors.ini")
    ap.add_argument("--check", action="store_true", help="report only, do not write")
    ap.add_argument(
        "--regular", type=float, default=5.0, help="min contrast, regular1-6"
    )
    ap.add_argument("--bright", type=float, default=7.0, help="min contrast, bright1-6")
    args = ap.parse_args()

    path = os.path.realpath(os.path.expanduser(args.file))
    try:
        with open(path) as f:
            lines = f.read().splitlines()
    except OSError as e:
        sys.exit(f"fix-contrast: {e}")

    if not section_backgrounds(lines):
        sys.exit(f"fix-contrast: no background= line found in {path}")

    new_lines, problems = process(
        lines, {"regular": args.regular, "bright": args.bright}
    )

    for sec, key, old, new, r_old, r_new in problems:
        arrow = "LOW" if args.check else f"-> #{new} ({r_new:.2f}:1)"
        print(f"[{sec}] {key}: #{old} ({r_old:.2f}:1) {arrow}", file=sys.stderr)

    if args.check:
        sys.exit(1 if problems else 0)
    if not problems:
        return

    tmp = path + ".tmp"
    with open(tmp, "w") as f:
        f.write("\n".join(new_lines) + "\n")
    shutil.copymode(path, tmp)
    os.replace(tmp, path)


if __name__ == "__main__":
    main()
