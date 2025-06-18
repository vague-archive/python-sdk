# Fiasco Python SDK

This repository holds the initial proof-of-concept of the Fiasco Python SDK.

> [!WARNING]
> Disclaimer: this has **not** been tested on Windows yet.

## Getting started

Setup the python virtual environment at the root of this project's directory:

```sh
python3 -m venv .venv
```

A folder named `.venv` should be created at the root, and should already be in the `.gitignore`.

Activate the virtual environment by running `source` on the activation script:

```sh
# Mac/Linux
source .venv/bin/activate

# Windows
.venv\Scripts\activate.bat
```

While in the venv, install the project dependencies:

```sh
pip install -r requirements.txt
```

To deactivate the venv, run: `deactivate`


## Compiling

To compile cython code to a standalone dynamic library that can be loaded by our engine, run the compile script with: `./compile.sh`. The output should be placed in the `modules` directory.

## Running

A copy of the engine has been pushed to this repo, just run `./platform_native` from the root of this project and if the `modules` directory was created after compiling then it should run the game that is in [src/sample/game.py](src/sample/game.py).
