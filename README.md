# Package Repository Tools

A set of tools for managing package installations on Arch Linux-based systems.

## Features

- Generate YAML reports of installed packages
- Restore packages from generated reports
- Support for official repositories and AUR
- Version tracking and matching
- Progress visualization
- Detailed logging
- Configurable options

## Requirements

- Arch Linux or Arch-based distribution
- bash 4.0+
- git (for AUR access)
- base-devel (for building AUR packages)

## Installation

```bash
git clone https://github.com/yourusername/package-repo-tools.git
cd package-repo-tools
sudo make install
```

## Usage

### Generate Package Report

```bash
report [options] [output-file]

Options:
  -v, --version        Show version
  -V, --verbose        Verbose output
  -p, --versions       Include package versions
  -h, --help          Show help
```

### Restore packages

```bash
restore [options] [input-file]

Options:
  -v, --version        Show version
  -V, --verbose        Verbose output
  -m, --match-versions Match package versions
  -h, --help          Show help
```

## Configuration

Create a configuration file at ~/.config/package-repo-tools/config to set default options:

```
# Default verbosity level (0-2)
VERBOSE=1

# Include versions in reports by default
INCLUDE_VERSIONS=0

# Match versions during restore
MATCH_VERSIONS=0
```

## Logs

Logs are stored in ~/.local/state/package-repo-tools/logs/ with timestamps.

## Dependencies

This project includes the `getoptions` library for command-line argument parsing.

- Original Author: Koichi Nakashima
- Source: https://github.com/ko1nksm/getoptions
- License: Creative Commons Zero v1.0 Universal

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License - see LICENSE file for details

## Acknowledgments

Special thanks to Koichi Nakashima for the getoptions library which is included in this project under the Creative Commons Zero v1.0 Universal license.
