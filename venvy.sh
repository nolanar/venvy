# A lightweight wrapper for the python 3.3+ venv utility

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
		echo "error: virtual enviroment '$1' is malformed: bin/activate does not exist"
		return 4
	fi

	# look for preactivate hook in $VENV_HOME
	if [ -f "$VENV_HOME/_HOOKS_/preactivate" ]; then
		source $VENV_HOME/_HOOKS_/preactivate
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

	# look for postactivate hook in $VENV_HOME
	if [ -f "$VENV_HOME/_HOOKS_/postactivate" ]; then
		source $VENV_HOME/_HOOKS_/postactivate
	fi

	return 0
}

# Deactivate the currently active virtual enviroment
stopenv () {
	# check that $VIRTUAL_ENV and the function deactivate are defined
	if [ -z "$VIRTUAL_ENV" ] || [ ! "`type -t deactivate`" = 'function' ]; then
		echo "error: no virtual enviroment currently active"
		return 1
	fi

	# look for predeactivate hook in $VENV_HOME
	if [ -f "$VENV_HOME/_HOOKS_/predeactivate" ]; then
		source $VENV_HOME/_HOOKS_/predeactivate
	fi

	# call the python venv defined deactivate function
	echo "deactivating virtual enviroment '$VIRTUAL_ENV'"
	deactivate
	ret=$?

	# look for postdeactivate hook in $VENV_HOME
	if [ -f "$VENV_HOME/_HOOKS_/postdeactivate" ]; then
		source $VENV_HOME/_HOOKS_/postdeactivate
	fi

	return $ret
}

# Create a new virtual enviroment
#
# If $VENV_HOME is defined then the new venv is created in that directory,
# otherwise it will be created in the current directory.
mkenv () {
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
	# start the newly created venv
	startenv "$1" || return $?
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
	if [ -e "$PROJECT_HOME/$1" ]; then
		echo "error: cannot create project '$1': File exists in $PROJECT_HOME"
		return 4
	fi

	# create new venv in $VENV_HOME
	mkenv "$1" || return $?
	# create and cd to new project directory
	echo "creating new project '$1' in $PROJECT_HOME"
	mkdir "$PROJECT_HOME/$1" || return $?
	cd "$PROJECT_HOME/$1" || return $?
	# create .project file in new venv containing path to project directory
	echo "$PROJECT_HOME/$1" > "$VENV_HOME/$1/.project" || return $?
	return 0
}


## INITIALISATION ##

# Check if $VENV_HOME is defined
if [ -n "$VENV_HOME" ]; then
	# create directory if it does not exist
	if [ ! -d "$VENV_HOME" ]; then
		echo "venvy: creating directory $VENV_HOME"
		mkdir -p "$VENV_HOME" || echo "venvy: could not create directory $VENV_HOME"
	fi

	# create any missing hooks from $VENV_HOME/HOOKS_
	for hook in preactivate postactivate predeactivate postdeactivate; do
		if [ ! -e "$VENV_HOME/_HOOKS_/$hook" ]; then
			echo "# $hook hook" > "$VENV_HOME/_HOOKS_/$hook"
		fi
	done
fi

# Setup tab completion
_venv_list_tab () {
	# list all directories in $VENV_HOME
	# cut trailing '/'
	# remove _HOOKS_ dir from list
	COMPREPLY=( $(compgen -W "`	[ -n $VENV_HOME ] &&
		cd $VENV_HOME &&
		ls -d -- */ | cut -d '/' -f 1 | grep -v '^_HOOKS_$'
		`" -- ${COMP_WORDS[COMP_CWORD]}))
}
complete -o default -o nospace -F _venv_list_tab startenv
