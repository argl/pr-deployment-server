run_or_fail() {
  "$@"      # Run all arguments as a command
  local status=$?
  if [ $status -ne 0 ]; then
    echo "❌ Command '$*' failed with status $status" >&2
    exit $status
  fi
}

checkout_pr_worktree() {
  local main_dir="${1}"
  local pr_number="${2}"
  
  run_or_fail cd ${main_dir}

  local branch="pr-${pr_number}"
  local worktree_dir="../pr-${pr_number}"

  # fail graciously if the worktree does not exist
  git worktree remove "${worktree_dir}" 2>/dev/null || true

  run_or_fail git fetch origin pull/"${pr_number}"/head:"${branch}"
  run_or_fail git worktree add "${worktree_dir}" "${branch}"

  echo "✅ Worktree for PR #${pr_number} added in: ${worktree_dir}"
}

pull_main() {
  local main_dir="${1}"
  run_or_fail cd ${main_dir}
  run_or_fail git reset --hard
  run_or_fail git pull
  echo "✅ Successfully updated main branch in ${main_dir}"
}

prepare_rari() {
  local main_dir="${1}"
  run_or_fail cd ${main_dir}
  run_or_fail git reset --hard
  run_or_fail cargo build -r
  echo "✅ Successfully built rari from ${main_dir}"
}

build_baseline() {
  echo "TBD"
}

repos=(
    mdn/yari
    mdn/rari
    mdn/content
    mdn/translated-content
    mdn/curriculum
    mdn/mdn-studio
    mdn/mdn-contributor-spotlight
    mdn/generic-content
 )