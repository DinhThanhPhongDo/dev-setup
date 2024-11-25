# Development Setup

Setting up a new development environment on a newly installed Debian / Ubuntu distribution. **dev-setup** uses the `setup.sh` script which will configure the following components automatically:

- Install `ncdu`, `htop`, `git`, `tmux`
- Set up `ssh` for git
- Install `docker`

## Installation

Download the script file using [wget](https://www.gnu.org/software/wget):

```bash
cd
wget -P ~/ https://github.com/DinhThanhPhongDo/dev-setup/archive/refs/heads/main.zip
unzip main
rm -r main.zip
sh dev-setup-main/main.sh
rm -r dev-setup-main
```
