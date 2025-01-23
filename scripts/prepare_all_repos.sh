#!/usr/bin/env bash

# Usage: ./prepare_all_repos.sh
# 
# This checks out the main branch of all the repos in the mdn org into a workdir structure

# set -x
set -e

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${script_dir}/functions.sh"

cd ~/github

for repo in "${repos[@]}"; do
    main_checkout_dir="${repo}/main"
    echo "   Checking out main branch of repo ${repo} into ${main_checkout_dir}"
    # removing any existing
    rm -rf ${main_checkout_dir} || true
    run_or_fail git clone git@github.com:${repo} ${main_checkout_dir}
    echo "✅ Checked out ${repo} into ${main_checkout_dir}"
done
