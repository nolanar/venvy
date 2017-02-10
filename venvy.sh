# A lightweight wrapper for the python 3.3+ venv utility

# Create a new virtual enviroment
mkvenv () {
	python3 -m venv "$@"
}