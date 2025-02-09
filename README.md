# Package Repository Tools

A comprehensive toolkit for managing Arch Linux package installations across systems.

## Features

- Generate YAML reports of installed packages
- Restore packages from YAML reports
- Smart repository detection and configuration
- Parallel installation support
- Progress visualization with pacman animation
- System resource verification
- Comprehensive logging
- Custom repository support
- GPG key management
- Dependency resolution
- Conflict handling

## Installation

From AUR:

```bash
    yay -S package-repo-tools
```

From source:

```bash
    git clone https://github.com/richardmajewski/package-repo-tools.git
    cd package-repo-tools
    make
    sudo make install
```

## Usage

### Generate Package Report

```bash
    package-repo-report [output_file]
```

### Restore Packages

```bash
    package-repo-restore [options] [input_file]

Options:
- `-d, --dry-run`: Show what would be installed
- `-p, --parallel`: Enable parallel installation
- `-v, --verbose`: Enable verbose output
- `-l, --log FILE`: Specify custom log file
- `-h, --help`: Show help message
```

## Configuration

Edit `/etc/package-repo-tools.conf` to customize:

- Repository definitions
- System resource thresholds
- Installation behavior
- Logging preferences

## Requirements

- bash
- curl
- pacman
- parallel
- yay (optional, for AUR support)

## License

MIT License - See LICENSE file for details

## Author

Richard Majewski
