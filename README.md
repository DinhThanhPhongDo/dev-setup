# Development Setup

Setting up a new development environment on a newly installed Debian / Ubuntu distribution. **dev-setup** uses the `setup.sh` script which will configure the following components automatically:

- Install `ncdu`, `git`, `tmux`
- Set up `ssh` for git
- Install `docker`

## Installation

Download the script file using [wget](https://www.gnu.org/software/wget):

```bash
sh -c "$(wget -O - https://github.com/DinhThanhPhongDo/dev-setup/raw/HEAD/setup.sh)"
```
