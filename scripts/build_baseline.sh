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

rm -r node_modules/gifsicle/ || true # WHY does it break after the frst build?
yarn install --frozen-lockfile || true

export CONTENT_ROOT=${script_dir}/../mdn/content/main/files
export CONTENT_TRANSLATED_ROOT=${script_dir}/../mdn/translated-content/main/files
export CONTRIBUTOR_SPOTLIGHT_ROOT=${script_dir}/../mdn/mdn-contributor-spotlight/main/contributors
export CURRICULUM_ROOT=${script_dir}/../mdn/curriculum/main
export BLOG_ROOT=${script_dir}/../mdn/mdn-studio/main/content/posts/
export GENERIC_CONTENT_ROOT=${script_dir}/../mdn/generic-content/main/files

export INTERACTIVE_EXAMPLES_BASE_URL=https://interactive-examples.mdn.allizom.net
export REACT_APP_FXA_SIGNIN_URL=/users/fxa/login/authenticate/
export REACT_APP_FXA_SETTINGS_URL=https://accounts.stage.mozaws.net/settings/
export REACT_APP_ENABLE_PLUS=true
export REACT_APP_PLACEMENT_ENABLED=true
export REACT_APP_DISABLE_AUTH=true
export BUILD_OUT_ROOT=${script_dir}/../build/main
export BUILD_LIVE_SAMPLES_BASE_URL=https://live.mdnyalp.dev
export BUILD_LEGACY_LIVE_SAMPLES_BASE_URL=https://live-samples.mdn.allizom.net
export REACT_APP_PLAYGROUND_BASE_HOST=mdnyalp.dev
export LIVE_SAMPLES_BASE_URL=https://live.mdnyalp.dev

run_or_fail yarn build:sw
run_or_fail yarn build:client
run_or_fail yarn build:ssr
run_or_fail yarn tool:legacy build-robots-txt
run_or_fail yarn rari build --all --issues ${BUILD_OUT_ROOT}/issues.json --templ-stats
run_or_fail yarn render:html

cd cloud-function
run_or_fail npm ci
run_or_fail npm run build-redirects
run_or_fail npm run build-canonicals

echo 'ORIGIN_MAIN="localhost" \
ORIGIN_LIVE_SAMPLES="localhost" \
SOURCE_CONTENT=http://localhost:8100/' > .env

# run cloud function
run_or_fail npm start


# other env variables in play
# DEFAULT_DEPLOYMENT_PREFIX: main
# DEFAULT_NOTES: 
# DEFAULT_LOG_EACH_SUCCESSFUL_UPLOAD: false
# DEPLOYER_BUCKET_PREFIX: main
# DEPLOYER_LOG_EACH_SUCCESSFUL_UPLOAD: false
# pythonLocation: /opt/hostedtoolcache/Python/3.10.16/x64
# PKG_CONFIG_PATH: /opt/hostedtoolcache/Python/3.10.16/x64/lib/pkgconfig
# Python_ROOT_DIR: /opt/hostedtoolcache/Python/3.10.16/x64
# Python2_ROOT_DIR: /opt/hostedtoolcache/Python/3.10.16/x64
# Python3_ROOT_DIR: /opt/hostedtoolcache/Python/3.10.16/x64
# LD_LIBRARY_PATH: /opt/hostedtoolcache/Python/3.10.16/x64/lib
# VENV: .venv/bin/activate
# CONTENT_ROOT: /home/runner/work/yari/yari/mdn/content/files
# CONTENT_TRANSLATED_ROOT: /home/runner/work/yari/yari/mdn/translated-content/files
# CONTRIBUTOR_SPOTLIGHT_ROOT: /home/runner/work/yari/yari/mdn/mdn-contributor-spotlight/contributors
# BLOG_ROOT: /home/runner/work/yari/yari/mdn/mdn-studio/content/posts
# CURRICULUM_ROOT: /home/runner/work/yari/yari/mdn/curriculum
# GENERIC_CONTENT_ROOT: /home/runner/work/yari/yari/mdn/generic-content/files
# BASE_URL: https://developer.allizom.org
# BUILD_OUT_ROOT: client/build
# LIVE_SAMPLES_BASE_URL: https://live.mdnyalp.dev
# INTERACTIVE_EXAMPLES_BASE_URL: https://interactive-examples.mdn.allizom.net
# ADDITIONAL_LOCALES_FOR_GENERICS_AND_SPAS: de
# BUILD_LIVE_SAMPLES_BASE_URL: https://live.mdnyalp.dev
# BUILD_LEGACY_LIVE_SAMPLES_BASE_URL: https://live.mdnyalp.dev
# BUILD_SAMPLE_SIGN_KEY: ***
# BUILD_INTERACTIVE_EXAMPLES_BASE_URL: https://interactive-examples.mdn.allizom.net
# BUILD_FLAW_LEVELS: *:ignore
# BUILD_GOOGLE_ANALYTICS_MEASUREMENT_ID: UA-36116321-5,G-ZG5HNVZRY0
# REACT_APP_ENABLE_PLUS: true
# REACT_APP_DISABLE_AUTH: false
# REACT_APP_INTERACTIVE_EXAMPLES_BASE_URL: https://interactive-examples.mdn.allizom.net
# REACT_APP_FXA_SIGNIN_URL: /users/fxa/login/authenticate/
# REACT_APP_FXA_SETTINGS_URL: https://accounts.stage.mozaws.net/settings/
# REACT_APP_MDN_PLUS_SUBSCRIBE_URL: https://accounts.stage.mozaws.net/subscriptions/products/prod_Jtbg9tyGyLRuB0
# REACT_APP_MDN_PLUS_5M_PLAN: price_1JFoTYKb9q6OnNsLalexa03p
# REACT_APP_MDN_PLUS_5Y_PLAN: price_1JpIPwKb9q6OnNsLJLsIqMp7
# REACT_APP_MDN_PLUS_10M_PLAN: price_1K6X7gKb9q6OnNsLi44HdLcC
# REACT_APP_MDN_PLUS_10Y_PLAN: price_1K6X8VKb9q6OnNsLFlUcEiu4
# REACT_APP_SURVEY_START_WEB_APP_AUGUST_2024: 0
# REACT_APP_SURVEY_END_WEB_APP_AUGUST_2024: 1723593600000
# REACT_APP_SURVEY_RATE_FROM_WEB_APP_AUGUST_2024: 0
# REACT_APP_SURVEY_RATE_TILL_WEB_APP_AUGUST_2024: 0.05
# REACT_APP_SURVEY_START_HOUSE_SURVEY_2025: 0
# REACT_APP_SURVEY_END_HOUSE_SURVEY_2025: 1737072000000
# REACT_APP_SURVEY_RATE_FROM_HOUSE_SURVEY_2025: 0
# REACT_APP_SURVEY_RATE_TILL_HOUSE_SURVEY_2025: 0.05
# REACT_APP_GLEAN_CHANNEL: stage
# REACT_APP_GLEAN_ENABLED: true
# REACT_APP_NEWSLETTER_ENABLED: true
# REACT_APP_PLACEMENT_ENABLED: true
# REACT_APP_PLAYGROUND_BASE_HOST: mdnyalp.dev
# REACT_APP_OBSERVATORY_API_URL: https://observatory-api.mdn.allizom.net
# SENTRY_DSN_BUILD: ***
# SENTRY_ENVIRONMENT: stage
# SENTRY_RELEASE: b47b0c7105be756f2be83990e3b8657458c3db09
