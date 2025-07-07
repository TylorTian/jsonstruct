.PHONY: install build upload clean test

install:
	. .venv/bin/activate && python -m pip install --upgrade pip setuptools wheel build twine --no-user

build:
	. .venv/bin/activate && python -m build

upload:
	. .venv/bin/activate && twine upload dist/*

test:
	. .venv/bin/activate && jsonstruct --help

clean:
	rm -rf dist build *.egg-info
