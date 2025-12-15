#!/bin/bash

EXECUTABLE=./VMtranslator

pushd /autograder/source/ >/dev/null

# remove old files
rm -f *.{vm,asm,tst}

# copy test files over
cp /autograder/grader/tests/${1}.{vm,tst} .

# run student-submitted code (untrusted)
runuser -u student -- ${EXECUTABLE} ${1}.vm

cp -f /autograder/grader/tests/expected-outputs/${1}.cmp .

popd >/dev/null
