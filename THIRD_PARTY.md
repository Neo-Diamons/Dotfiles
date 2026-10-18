# Third-party material

The repository is MIT ([LICENSE.md](LICENSE.md)). This page lists what is not covered by it.

## Included in the repository

| What                           | Where                                | Licence                                                  |
| ------------------------------ | ------------------------------------ | -------------------------------------------------------- |
| Terminus 14 px bitmap font     | `roles/grub/files/theme/ter-14.pf2`  | SIL OFL 1.1, text in [OFL.txt](roles/grub/files/theme/OFL.txt)    |

`ter-14.pf2` is converted with `grub-mkfont` from `ter-u14n.bdf` (Terminus Font 4.49.1, Dimitar Toshkov Zhekov) and renamed `ter`, since the licence reserves the name "Terminus Font".

## Downloaded when the playbook runs

Nothing below is stored in the repository.

| What                                                                              | Licence                  | Used by                                          |
| --------------------------------------------------------------------------------- | ------------------------ | ------------------------------------------------ |
| [gruvbox-plus-icon-pack](https://github.com/SylEleuth/gruvbox-plus-icon-pack)     | GPL-3.0                  | `roles/theme`, release archive checked by SHA-256 |
| [phinger-cursors](https://github.com/phisch/phinger-cursors)                      | CC BY-SA 4.0             | `roles/theme`, release archive checked by SHA-256 |
| [zinit](https://github.com/zdharma-continuum/zinit)                               | MIT                      | `roles/zsh`, pinned commit                       |
| [vis-commentary](https://github.com/lutobler/vis-commentary)                      | MIT                      | `roles/vis`, pinned commit                       |
| [vis-lspc](https://gitlab.com/muhq/vis-lspc)                                      | GPL-3.0-or-later | `roles/vis`, pinned commit |
| [community.general](https://github.com/ansible-collections/community.general)     | GPL-3.0-or-later         | Ansible collection in `requirements.yml`         |
| Zen browser extensions                                                            | each its own licence     | installed from addons.mozilla.org                |
