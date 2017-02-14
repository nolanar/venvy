# venvy
A lightweight wrapper for the [python 3.3+ venv utility](https://docs.python.org/3.3/library/venv.html)

## Setup
Run the `venvy.sh` script:
```bash
source /path/to/venvy.sh
```
This line should be added to your shell startup script (`.bashrc`, `.profile` etc.)

### Virtual enviroment directory
If the `VENV_HOME` enviroment variable is defined as a directory then newely created virtual enviroments are created there. If not defined then newely created virtual enviroments are created in the working directory. Add:
```bash
export VENV_HOME=/path/to/venv_home
```
to you shell startup script (`.bashrc`, `.profile` etc.) if you wish to use a virtual enviroment home directory.

## Commands
* `mkenv ENV_NAME` :- create a new virtual enviroment
* `mkproj PROJ_NAME` :- create a new virtual enviroment in $VENV_HOME and project in $PROJCET_HOME
* `startenv ENV_NAME` :- activate a virtual enviroment stored in $VENV_HOME
* `stopenv` :- deactivate the currently active virtual enviroment

## Hooks
Hooks are used to run user defined scripts before or after commands. The following hooks can be configured in the `$VENV_HOME/_HOOKS_` directory:
* `preactivate` :- run before startenv
* `postactivate` :- run after startenv
* `predeactivate` :- run before stopenv
* `postdeactivate` :- run after stopenv
