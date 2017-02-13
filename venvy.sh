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
	
	declare ret
	# create new venv in $VENV_HOME if it exists
	if [ -d "$VENV_HOME" ]; then 
		echo "creating new virtual enviroment '$1' in $VENV_HOME"
		python3 -m venv "$VENV_HOME/$1"
		ret=$?
	else # in current directory
		echo "creating new virtual enviroment '$1' in current directory"
		python3 -m venv "./$1"
		ret=$?
	fi
	return $ret
}

# Create a new virtual enviroment, and associated project in $PROJECT_HOME
mkproj () {
	# check that a single argument is passed
	if [ $# -ne 1 ]; then
		echo "usage: mkproj ENV_NAME"
		return 1
	fi
	# check that $VENV_HOME is a valid directory
	if [ ! -d "$VENV_HOME" ]; then
		echo "error: \$VENV_HOME must be set to a valid directory to use mkproj"
		return 2
	fi	
	# check that $PROJECT_HOME is a valid directory
	if [ ! -d "$PROJECT_HOME" ]; then
		echo "error: \$PROJECT_HOME must be set to a valid directory to use mkproj"
		return 3
	fi
	# check that a project of the specified name does not already exist
	if [ -d "$PROJECT_HOME/$1" ]; then
		echo "error: cannot create project '$1': already exists in $PROJECT_HOME"
	fi

	# create new venv in $VENV_HOME
	echo "creating new virtual enviroment '$1' in $VENV_HOME"
	python3 -m venv "$VENV_HOME/$1" || return $?
	# create and cd to new project directory
	echo "creating new project '$1' in $PROJECT_HOME"
	mkdir "$PROJECT_HOME/$1" || return $?
	cd "$PROJECT_HOME/$1" || return $?
	# create .project file in new venv containting path to project directory
	echo "$PROJECT_HOME/$1" > "$VENV_HOME/$1/.project" || return $?
	return 0
}

# Activate a virtual enviroment that is stored in $VENV_HOME
startenv () {
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
	source "$VENV_HOME/$1/bin/activate" || return $?
	# look for .project file in venv and cd to contained directory if it exists
	if [ -f "$VENV_HOME/$1/.project" ]; then
		proj_path=`cat "$VENV_HOME/$1/.project"`
		if [ -d $proj_path ];then
			cd $proj_path
		fi
	fi
	return 0
}

# Deactivate the currently active virtual enviroment
stopenv () {
	# check that $VIRTUAL_ENV and the function deactivate are defined
	if [ -z "$VIRTUAL_ENV" ] && [ ! "`type -t deactivate`" = 'function' ]; then
		echo "error: no virtual enviroment currently active"
		return 1
	fi

	# call the python venv defined deactivate function
	echo "deactivating virtual enviroment '$VIRTUAL_ENV'"
	deactivate
	ret=$?

	return $ret
}

## INITIALISATION CHECKS ##

# Check that $VENV_HOME is a valid directory if defined
if [ -n "$VENV_HOME" ] && [ ! -d "$VENV_HOME" ]; then
	echo "venvy: warning: \$VENV_HOME is not set to a valid directory hence will be ignored"
fi

# Set up tab completion
_venv_list_tab () {
		COMPREPLY=( $(compgen -W "`	[ -n $VENV_HOME ] &&
			cd $VENV_HOME &&
			ls -d -- */ | cut -d '/' -f 1
			`" -- ${COMP_WORDS[COMP_CWORD]}))
}
complete -o default -o nospace -F _venv_list_tab startenv
unset _venv_list