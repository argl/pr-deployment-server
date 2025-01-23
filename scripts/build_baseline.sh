#!/usr/bin/env bash

# Usage: ./build_baseline.sh
#
# Builds the baseline site from main branch in all repos

set -x
set -e

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "${script_dir}/functions.sh"

# for repo in "${repos[@]}"; do
#     main_checkout_dir="${repo}/main"
#     cd ${script_dir}/../${main_checkout_dir}
#     run_or_fail git reset --hard
#     run_or_fail git pull
#     echo "✅ Checked out main branch in ${repo}"
# done
# echo "✅ All repos are on the current main branch"

run_or_fail parallel -k --jobs 8 '
  cd '"$script_dir"'/../{}/main
  git reset --hard
  git pull
  echo "✅ Checked out main branch in {}"
' ::: "${repos[@]}"

cd ${script_dir}/../mdn/yari/main
# run_or_fail yarn install

export CONTENT_ROOT=${script_dir}/../mdn/content/main/files
export CONTENT_TRANSLATED_ROOT=${script_dir}/../mdn/translated-content/main/files
export CONTRIBUTOR_SPOTLIGHT_ROOT=${script_dir}/../mdn/mdn-contributor-spotlight/main/contributors
export CURRICULUM_ROOT=${script_dir}/../mdn/curriculum/main
export BLOG_ROOT=${script_dir}/../mdn/mdn-studio/main/content/posts/
export GENERIC_CONTENT_ROOT=${script_dir}/../mdn/generic-content/main/files

export INTERACTIVE_EXAMPLES_BASE_URL=https://interactive-examples.mdn.mozilla.net
export REACT_APP_FXA_SIGNIN_URL=/users/fxa/login/authenticate/
export REACT_APP_FXA_SETTINGS_URL=https://accounts.stage.mozaws.net/settings/
export REACT_APP_ENABLE_PLUS=true
export REACT_APP_PLACEMENT_ENABLED=true
export BUILD_OUT_ROOT=/tmp/build-fix-fr
run_or_fail yarn build
