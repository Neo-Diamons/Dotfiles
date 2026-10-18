# Conventions

## Repository

| Folder            | Holds                                                                           |
| ----------------- | ------------------------------------------------------------------------------- |
| `home/`           | Mirror of `~` with real names and paths, copied as-is                           |
| `templates/`      | Per-machine files only, mirroring `~` with a `.j2` suffix, rendered on apply    |
| `inventory/`      | `hosts.yml`, `group_vars/` (shared values) and `host_vars/` (one file per host) |
| `roles/`          | One role per job (see Ansible)                                                  |
| `site.yml`        | The playbook: role order, tags, host checks                                     |
| `CONVENTIONS.md`  | This file                                                                       |
| `.githooks/`      | Git hooks (`pre-commit` runs `ansible-lint`)                                  |

- A file goes in `home/` unless it differs per machine; then it becomes a template, never a copy per host.
- Generated files (wallust colours, `.qmlls.ini`) are never in the repo.
- No personal data: no IP, user name, key or password. A host's address and user live in `~/.ssh/config`.
- Delete empty folders: git does not track them and the playbook does not create them.

## Ansible

### Roles

| Role         | Does                                                                      |
| ------------ | ------------------------------------------------------------------------- |
| `packages`   | pacman packages, login shell, `-e debloat=true` removals                  |
| `rust`       | rustup toolchain and cargo crates                                         |
| `flatpak`    | Flathub remote and flatpaks                                               |
| `theme`      | Icon and cursor themes (checksum-verified), flatpak override, `gsettings` |
| `browser`    | Zen policy (extensions and settings)                                      |
| `wallpapers` | Upload from the controller (remote hosts only)                            |
| `dotfiles`   | Copy `home/`, render `templates/`, manifest, orphans, wallust, reload     |
| `vis`        | Pinned vis plugins (git clones, not vendored)                             |
| `zsh`        | Pinned zinit clone (plugins are fetched by zinit itself)                  |
| `greeter`    | greetd login screen, Quickshell greeter (`greeter` trait)                 |
| `system`     | Services and files outside `~` (needs `become`)                           |
| `grub`       | GRUB theme and kernel command line (needs `become`)                       |

A new job gets its own role and its own tag in `site.yml`; do not grow a role into a grab bag.

### Variables

- Shared values live in `inventory/group_vars/all/` (`main`, `packages`, `flatpaks`, `zen`); per-host differences only in `inventory/host_vars/<host>.yml`.
- A host describes what it is (`gpu`, `laptop`, `hybrid_gpu`, `sunshine`, `greeter`, `monitors`), not what to install. Package groups and settings are derived from those traits.
- The first entry of `monitors` is the main monitor (bar and cursor start).
- Values private to a role go in `roles/<role>/vars/main.yml` and start with the role name (`dotfiles_`, `theme_`).
- Command-line switches (`force`, `prune`, `reload`, `debloat`, `extensions`) are booleans with a default of `false`, used as `{{ x | bool }}`; the only role-less names allowed.
- Downloads are pinned by version and `sha256`; update both together.

### Tasks

- Every task has a name; modules use their full name (`ansible.builtin.copy`).
- `become` is set once on a block or on the role in `site.yml`, never repeated per task.
- `--check` must have no side effect and must not fail on a fresh machine.
- `changed_when` tells the truth: a command that can change something reports it; a read-only one is `changed_when: false`.
- One command for many files, not one task per file (the apply must stay fast over SSH).
- Logic too long for Jinja goes in a filter plugin with tests, not in a `set_fact`.
- A group of tasks sharing a condition sit in a `block` with one `when`.
- Handlers use `listen` and only reload what changed; they are skipped when the play fails.
- Comments say why (a workaround, an ordering constraint), not what the task already says.

### Checks

- `ansible-lint` must report 0 warnings.
- Run `ansible-playbook site.yml -l <host> --check --diff` before every apply.
- `-K` (sudo password) is only needed for `packages`, `flatpak`, `system`, `greeter` and `grub`; `-k` (SSH password) only for remote hosts.

## Quickshell

### Layout

| Folder        | Holds                                                                                             |
| ------------- | ------------------------------------------------------------------------------------------------- |
| `shell.qml`   | Entry point                                                                                       |
| `config/`     | `Config.qml` (behaviour), `Theme.qml` (sizes, fonts, motion), `Colors.qml` (generated by wallust) |
| `components/` | Generic `Brutal*` building blocks                                                                 |
| `modules/`    | One folder per window or popup                                                                    |
| `services/`   | State and system access (singletons)                                                              |
| `utils/`      | Stateless helpers (singletons)                                                                    |
| `scripts/`    | Python helpers; shared code in `scripts/lib/`                                                     |

A file used only by one module stays in that module; it moves to `components/` once something else needs it.

### Imports

- Use `import qs.<folder>` (`qs.config`, `qs.components`, `qs.services`, `qs.modules.bar`…).
- No `qmldir` files: Quickshell generates them, a hand-written one breaks editor completion.

### Comments

- Each QML file starts with a one-line description of what it is, above its root object. Components may list their modes below it.
- Otherwise, comment only workarounds and complex code: one line, before the block.
- Prefer clear names to comments. `config/` is the exception: section labels and units (`// ms`) are welcome.
- Glyphs are written as the character itself. Only invisible characters use an escape, with a comment saying what it is.

### State across reloads

- Use `PersistentProperties` (memory only, never written to disk).
- Store arrays / objects as JSON strings: JS values can't cross into the next reload's engine.
- `qs ipc call shell reload` is a hard reload and drops this state; saving a file triggers a soft reload that keeps it.

### Scripts

- Python 3, standard library only; run as `python3 scripts/<name>.py <command>`.
- Scripts called from QML (`Quickshell.shellDir + "/scripts/<name>.py"`) print JSON on stdout.
- Warnings go through `lib.log.print_warning`; shared logic lives in `scripts/lib/`.

### Checks

- After a change, check `qs log` for warnings.
