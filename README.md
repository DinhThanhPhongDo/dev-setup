# Development Setup

Setting up a new development environment on a newly installed Ubuntu distribution. **dev-setup** uses the `install.sh` script which will configure the following components automatically:

- Install `ncdu`, `git`
- Set up `ssh` for git
- Install `docker`

## Installation

Download the script file using [wget](https://www.gnu.org/software/wget):

```bash
sh -c "$(wget -O - https://github.com/DinhThanhPhongDo/dev-setup/raw/HEAD/install.sh)"
```
