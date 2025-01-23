#!/usr/bin/env bash

# Usage: ./checkout-pr-branch.sh <PR-NUMBER>

set -x
set -e

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${script_dir}/functions.sh"


repo="$1"
if [ -z "${repo}" ]; then
  echo "❌ Missing repository name. Usage: checkout_pr_worktree <REPO> <PR-NUMBER>"
  exit 1
fi

pr_number="$2"
if [ -z "${pr_number}" ]; then
  echo "❌ Missing PR number. Usage: checkout_pr_worktree <PR-NUMBER>"
  return 1
fi

repo_main_dir="${script_dir}/../${repo}/main"

pull_main ${repo_main_dir}
checkout_pr_worktree ${repo_main_dir} ${pr_number}
