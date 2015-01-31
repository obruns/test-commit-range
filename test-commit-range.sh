#!/bin/sh

#
# Purpose
# -------
#
# To test a range of commits prior to pushing upstream

# Implementation
# --------------
#
# Check the following steps
# * cmake
# * make
# * run tests (needs manual fix of the script)
#
# for each step write 'step: true|false' to a file that is valid YAML
#

if [[ $# -ne 3 ]]
then
    echo "Usage: $0 <logfile> <range_start> <range_end>"
    exit 1
fi

RETURN_TO=`git log -1 --format='%h'`

LOGFILE=$1
RANGE_START=$2
RANGE_END=$3

function writeResult()
{
    SUCCESS=$1
    KEY=$2

    if [[ ${SUCCESS} -ne 0 ]]
    then
        echo "    ${KEY}: false" >> ${LOGFILE}
    else
        echo "    ${KEY}: true"  >> ${LOGFILE}
    fi
}

# put anything that is required for each commit here, e.g.
# export PATH=${HOME}/.local/bin:${PATH}
for sha1 in `git log --reverse --format='%h' "${RANGE_START}..${RANGE_END}"`
do
    echo "- ${sha1}:" >> ${LOGFILE}
    git reset --hard ${sha1}

    # you may want to apply something from the stash but make sure
    # you don't break the purpose of this script (ensuring your commits
    # are fine)
    # git stash apply --quiet


    # invoke your configure step here, e.g.
    # rm -Rf build && mkdir build && cd build && CC=clang CXX=clang++ cmake -G Ninja ../
    # if incremental builds are fine for you, shorten the build cycles
    # by not removing the output directory
    writeResult $? "cmake"


    # invoke your build command here, e.g.
    # ninja
    writeResult $? "ninja"

    # invoke all your unit tests here
    writeResult $? "test"

    # invoke your integration tests, acceptance tests, whatever
    writeResult $? "at"

    # ... more?

    cd ../
done

git reset --hard ${RETURN_TO}
