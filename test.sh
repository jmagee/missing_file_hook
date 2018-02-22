#!/bin/bash

test_repo="test_repo"

pushd() {
  command pushd $* > /dev/null
}

popd() {
  command popd $* > /dev/null
}

create_test_repo() {
  mkdir $test_repo
  git init $test_repo
}

destroy_test_repo() {
  rm -rf $test_repo
}

install_hook() {
  ./git-install-missing-file-hook $test_repo
}

create_file() {
  filename=$1
  contents=$2

  echo $contents > $test_repo/$filename
}

add_file() {
  filename=$1
  pushd $test_repo
  git add $filename
  popd
}

commit() {
  pushd $test_repo
  git commit -a -m "Test"
  ret=$?
  popd
  return $ret
}

reset() {
  cd $test_repo
  git reset HEAD~1
  popd
}

expect_failure() {
  if [ "$1" != "1" ]; then
    echo ": Test failed"
    return 1
  else
    echo ": Test passed"
    return 0
  fi
}

expect_success() {
  if [ "$1" != "1" ]; then
    echo ": Test passed"
    return 0
  else
    echo ": Test failed"
    return 1
  fi
}

overall_result=0

create_test_repo
install_hook

echo "CHECK: Running a positive sanity test"

create_file foo.c "#include \"foo.h\""
create_file foo.h "static int x;"

add_file foo.c
commit
result=$?

expect_failure $result
overall_result=$(($overall_result || $?))

echo ------------------------
echo "CHECK: Running a negative sanity test"
create_file foo.c "#include \"bar.h\""
create_file foo.h "static int x;"

add_file foo.c

commit
result=$?
expect_success $result
overall_result=$(($overall_result || $?))

destroy_test_repo

exit $overall_result
