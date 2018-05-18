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

create_dir() {
  dirname=$1

  mkdir -p $test_repo/$dirname
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

clean() {
  pushd $test_repo
  git reset > /dev/null 2>&1
  git clean -f > /dev/null 2>&1
  popd
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

create_file foo1.c "#include \"foo1.h\""
create_file foo1.h "static int x;"

add_file foo1.c
commit
result=$?

expect_failure $result
overall_result=$(($overall_result || $?))
clean

echo ------------------------
echo "CHECK: Running a negative sanity test"
create_file foo2.c "#include \"bar.h\""
create_file foo2.h "static int x;"

add_file foo2.c

commit
result=$?
expect_success $result
overall_result=$(($overall_result || $?))
clean

echo "CHECK: Running a nested file test"

create_dir dir/a
create_dir dir/b
create_file dir/a/foo3.c "#include \"foo3.h\""
create_file dir/b/foo3.h "static int x;"

add_file dir/a/foo3.c
commit
result=$?

expect_failure $result
overall_result=$(($overall_result || $?))
clean

destroy_test_repo

exit $overall_result
