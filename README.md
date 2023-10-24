# PROJECT NAME
One line (or more) about what this project does

<!-- Examples:

- Cross-platform C++ library to drive native hearing tests.
- Podspec repo for all of internal components
-->

## Getting started

Download the [latest version](https://github.com/MimiHearingTechnologies/RepoTemplate-GitHub/releases) and execute in the terminal:

```
$ ./tool
tool -i input -o output [-p parameter_set] [--verbose]
```

Examples:
```
$ ./tool -i in_files/ -o out_files        # process all files inside in_files, save to output_files
$ ./tool -i in_files/audio.wav --verbose  # print verbose information
```

<!-- Include screenshot if applicable -->

## Developers

### Build instructions
This project only works on Python 3.6+!

```
brew install poetry                       # install 'poetry' for dependency management
git submodule update --init --recursive   # pull in git submodules
poetry install                            # install project dependencies
```

### Running test / lint
```
poetry run lint    # lint project
poetry run test    # run tests/*.py
```
