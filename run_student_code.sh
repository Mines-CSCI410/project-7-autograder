#!/bin/bash

EXECUTABLE=./VMtranslator

pushd /autograder/source/ >/dev/null

# remove old files
rm -f *.{vm,asm,tst}

# copy test files over
cp /autograder/grader/tests/${1}.{vm,tst} .
cp /autograder/grader/tests/expected-outputs/${1}.cmp .

# run student-submitted code (untrusted)
runuser -u student -- ${EXECUTABLE} $(pwd)/${1}.vm

popd >/dev/null
