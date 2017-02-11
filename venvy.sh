# A lightweight wrapper for the python 3.3+ venv utility

# Create a new virtual enviroment
#
# If $VENV_HOME is defined then the new venv is created in that directory,
# otherwise it will be created in the current directory.
mkvenv () {
	# check that a single argument is passed
	if [ $# -ne 1 ]; then
		echo "usage: mkvenv ENV_NAME"
		return 1
	fi
	
	typedef RC
	# create new venv in $VENV_HOME if it exists
	if [ -d "$VENV_HOME" ]; then 
		echo "creating new virtual enviroment '$1' in $VENV_HOME"
		python3 -m venv "$VENV_HOME/$1" && RC=$?
	else # in current directory
		echo "creating new virtual enviroment '$1' in current directory"
		python3 -m venv "./$1" && RC=$?
	fi
	return RC
}

# Activate a virtual enviroment that is stored in $VENV_HOME
actvenv () {
	# check that that a single argument was passed
	if [ $# -ne 1 ]; then
		echo "usage: actvenv ENV_NAME"
		return 1
	fi
	# check that $VENV_HOME is a valid directory
	if [ ! -d "$VENV_HOME" ]; then
		echo "error: \$VENV_HOME must be set to a valid directory to use actvenv"
		return 2
	fi
	# check that the venv dir exitst in $VENV_HOME
	if [ ! -d "$VENV_HOME/$1" ]; then
		echo "error: virtual enviroment '$1' does not exit in $VENV_HOME"
		return 3
	fi
	# check that venv contains the bin/activate script
	if [ ! -f "$VENV_HOME/$1/bin/activate" ]; then
		echo "error: virtual enviroment '$1' is malformed: bin/activte does not exist"
		return 4
	fi

	# activate venv
	echo "activating virtual enviroment '$1'"
	source "$VENV_HOME/$1/bin/activate"
	return 0
}

## INITIALISATION CHECKS ##

# Check that $VENV_HOME is a valid directory if defined
if [ -n "$VENV_HOME" ] && [ ! -d "$VENV_HOME" ]; then
	echo "venvy: warning: \$VENV_HOME is not set to a valid directory hence will be ignored"
fi
