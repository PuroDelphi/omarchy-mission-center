# Third-party notices

This project packages or installs the following third-party components. Their licenses are listed below.

## Components

| Component | Type | License | Source |
|---|---|---|---|
| [mission-center](https://archlinux.org/packages/extra/x86_64/mission-center/) | System package (GPL) | GPL-3.0-or-later | Arch Linux extra |
| [nethogs](https://archlinux.org/packages/extra/x86_64/nethogs/) | System package | GPL-2.0-or-later / GPL (Arch) | Arch Linux extra |
| [fzf](https://github.com/junegunn/fzf) | Runtime dependency (TUI) | MIT | Arch/used by startup-manager |

## Notes on license compatibility

- This repo's own code (`install.sh`, `bin/startup-manager`, `fragments/*`, documentation) is licensed under [MIT](LICENSE) by **Jhonny Suarez - PuroDelphi**.
- We only install system packages via `omarchy pkg add` / `pacman`; we do not redistribute their binaries, source, or license texts. The user already has access to those packages under their respective licenses on Arch Linux.
- `startup-manager` uses `fzf` (MIT). MIT is compatible with GPL.
- Aggregating an installer that pulls GPL-licensed packages does not create a derivative work of those packages for distribution purposes here. No GPL source/binaries are included in this repository.

For the most up-to-date license texts, refer to the upstream projects above.
