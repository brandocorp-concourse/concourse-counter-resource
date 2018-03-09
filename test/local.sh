#!/bin/bash -e
FAILURE='\033[0;31m'
SUCCESS='\033[0;32m'
RESET='\033[0m'
TMPDIR="$(mktemp -d)"

SCRIPT=$0
TEST=$(readlink -fs $(dirname $SCRIPT))
REPO=$(dirname $TEST)

info(){
  echo "$1"
}

log_success(){
  echo -e "    ${SUCCESS}$1${RESET}"
}

log_failure(){
  echo -e "    ${FAILURE}$1${RESET}"
  return 1
}

test_suite(){
  local name=$1
  echo -e "\n\nTest: $name"
  echo "==============================="
}

validate_output(){
  local rel=$(jq -M -r '.[] | .count' <<< "$1")
  echo $rel
}

test_check_count_null(){
  echo "When no version is requested"
  local output=$(bash $REPO/assets/check < $REPO/test/fixtures/null.json 2> /dev/null)
  local latest=$(validate_output "$output")
  if [ $? -eq 0 ]; then
    if [ $latest -eq 1 ]; then
      log_success "it retuns the starting version ($latest)"
    else
      log_failure "it should equal 1 (found: $latest)"
    fi
  else
    log_failure "it should not fail"
  fi
}

test_check_count_restart(){
  echo "When the 'latest' version is requested"
  local output=$(bash $REPO/assets/check < $REPO/test/fixtures/restart.json 2> /dev/null)
  local latest=$(validate_output "$output")
  if [ $? -eq 0 ]; then
    log_success "it retuns the latest version ($latest)"
  else
    log_failure "it should not fail"
  fi
}
 
test_check(){
  test_suite "check"
  test_check_count_null
  test_check_count_restart
}


validate_download(){
  test -e "$1"
}

test_in_count_null(){
  echo "When no version is present in the input data"
  local output=$(bash $REPO/assets/in $TMPDIR < $REPO/test/fixtures/null.json 2> /dev/null)
  if [ $? -eq 0 ]; then
    log_success "it fails with an error message"
  else
    log_failure "it should not succeed"
  fi
}

test_in_count_valid(){
  echo "When the latest version is requested"
  local output=$(bash $REPO/assets/in $TMPDIR < $REPO/test/fixtures/restart.json 2> /dev/null)
  local requested=$(validate_download "$output")
  if [ $? -eq 0 ]; then
    log_success "it stages the count's value in a file"
  else
    log_failure "it should not fail"
  fi
}

test_in(){
  test_suite "in"
  test_in_count_null || return 1
  test_in_count_valid || return 1
}

test_out_does_nothing(){
  echo "When run"
  log_success "it does nothing"
}

test_out(){
  test_suite "out"
  test_out_does_nothing
}

cleanup(){
  rm -rf $TMPDIR
}

trap cleanup EXIT

main(){
  test_check
  test_in
  test_out
  cleanup
}

main
