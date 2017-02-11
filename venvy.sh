# A lightweight wrapper for the python 3.3+ venv utility

# Create a new virtual enviroment
#
# If $VENV_HOME is defined then the new venv is created in that directory,
# otherwise it will be created in the current directory.
mkvenv () {
	typeset RC
	# check that a single argument is passed
	if [ $# -eq 1 ]; then
		# check if $VENV_HOME is defined
		if [ ! -d "$VENV_HOME" ]; then
			echo "creating new virtual enviroment $1 in $VENV_HOME"
			python3 -m venv "$VENV_HOME/$1" && RC=$?
		else
			echo "creating new virtual enviroment $1 in current directory"
			python3 -m venv "./$1" && RC=$?
		fi
	else
		echo "usage: mkvenv ENV_NAME"
		RC=1
	fi
	return $RC
}

## INITIALISATION CHECKS ##

# Check that $VENV_HOME is a valid directory if defined
if [ -n "$VENV_HOME" ]; then
	if [ ! -d "$VENV_HOME" ]; then
		echo "venvy: warning: \$VENV_HOME is not set to a valid directory hence will be ignored"
	fi
fi
