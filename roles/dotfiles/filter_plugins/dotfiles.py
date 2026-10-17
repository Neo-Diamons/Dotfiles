"""Filters used by the dotfiles role to plan an apply.

Data shapes:
  item      a managed file: {"path": "<relative to ~>", ...} (repo file or rendered template)
  checksums {"<relative path>": "<sha1>"}
  modes     {"<relative path>": "<octal mode>"}

The live files are described by `sha1sum` lines ("<40 hex>  <path>") and
`stat -c '%a  %n'` lines ("<mode>  <path>"), mixed in one output.
"""

SHA1_LENGTH = 40


def _parse(lines, want_sums):
    out = {}
    for line in lines:
        value, _, path = line.partition("  ")
        if (len(value) == SHA1_LENGTH) == want_sums:
            out[path.removeprefix("./")] = value
    return out


def sums_to_dict(lines):
    """Checksums found in `sha1sum` output lines (a leading ./ is dropped)."""
    return _parse(lines, want_sums=True)


def modes_to_dict(lines):
    """Modes found in `stat -c '%a  %n'` output lines."""
    return _parse(lines, want_sums=False)


def wanted_sums(repo, rendered):
    """Checksums every managed file should have: repo files plus rendered templates."""
    return {**repo, **{r["path"]: r["sum"] for r in rendered}}


def files_to_copy(items, live, wanted, modes):
    """Items missing on disk, with another content, or with another mode."""
    def mode_differs(item):
        live_mode = modes.get(item["path"])
        return live_mode is not None and int(live_mode, 8) != int(item["mode"], 8)

    return [i for i in items if live.get(i["path"]) != wanted[i["path"]] or mode_differs(i)]


def conflicts(items, live, wanted, previous):
    """Paths edited outside the repo: live differs from wanted AND from the last apply."""
    def edited(path):
        sum_live = live.get(path)
        return sum_live is not None and sum_live != wanted[path] and sum_live != previous.get(path)

    return [i["path"] for i in items if edited(i["path"])]


def manifest(wanted, orphans, previous, keep_orphans):
    """Checksums to record: the wanted ones, plus orphans left on disk (when not pruned)."""
    kept = {path: previous[path] for path in orphans} if keep_orphans else {}
    return {**kept, **wanted}


class FilterModule:
    def filters(self):
        return {
            "dotfiles_sums": sums_to_dict,
            "dotfiles_modes": modes_to_dict,
            "dotfiles_wanted": wanted_sums,
            "dotfiles_to_copy": files_to_copy,
            "dotfiles_conflicts": conflicts,
            "dotfiles_manifest": manifest,
        }
