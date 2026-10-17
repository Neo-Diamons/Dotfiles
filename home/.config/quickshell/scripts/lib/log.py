"""Coloured stderr messages."""

import sys
from pathlib import Path

YELLOW = "\033[1;33m"
CYAN = "\033[1;36m"
GRAY = "\033[90m"
RESET = "\033[0m"


def print_warning(filename: str, err: Exception) -> None:
    use_color = sys.stderr.isatty()

    yellow = YELLOW if use_color else ""
    cyan = CYAN if use_color else ""
    gray = GRAY if use_color else ""
    reset = RESET if use_color else ""

    err_msg = err.args[0] if err.args else str(err)

    print(
        f"{yellow}[WARNING]{reset} {cyan}{Path(filename).name}{reset} {gray}—{reset} {err_msg}",
        file=sys.stderr,
    )
