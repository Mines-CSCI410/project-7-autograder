# Autograder For Project 7 Virtual Machine

## Submission Requirements

### Setup
Each submitted project should contain a bash script named `setup.sh` that is
responsible for building the executable.

Some languages, such as python, will not need to build anything, but should
still contain an empty `setup.sh` file.

### Executable
The executable should be named `VMtranslator`.

For interpreted languages, such as python, where your program cannot be built
into an executable, use a bash script to call their program *passing through
any arguments*.

Python Example:
```bash
#!/bin/bash

python3 VMtranslator.py $@
```
