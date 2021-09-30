#!/usr/bin/env bash

set -euo pipefail

deploy_script_dir="$(readlink -f "$0" | xargs dirname)"; readonly deploy_script_dir

tarball_url() {
  local -r owner="$1"
  local -r repo="$2"
  local -r rev="$3"

  echo "https://github.com/${owner}/${repo}/tarball/${rev}"
}

# === BEGIN parameterization ===
owner="${GH_OWNER:-awseward}"
repo="${GH_REPO_NAME:-spiderman-points}"
rev="${1:-main}"
app_name="${APP_NAME:-spoints}"
daemon_name="${DAEMON_NAME:-${app_name}d}"
# === END parameterization ===

deploy_name="${app_name}-$(date +'%Y%m%d%H%M%S')"

download_dir="${HOME}/.cache/deploy/${deploy_name}"
data_basedir="${HOME}/.local/share/deploy"

mkdir -p "${download_dir}" "${data_basedir}"

cd "${download_dir}"
wget "$(tarball_url "${owner}" "${repo}" "${rev}")"
extracted_dir="$(tar -zxvf "${rev}" | head -n1)"

link_source_dirpath="${data_basedir}/${deploy_name}"
link_target_dirpath="${HOME}/${app_name}"

mv "${extracted_dir}" "${link_source_dirpath}"

cd "${link_source_dirpath}"
xargs -t rm -vf < .slugignore

# === BEGIN app-specific setup ===
"${deploy_script_dir}/on_deploy.sh"
# === END app-specific setup ===

# I've found if you don't delete this first, it tends to start doing weird
# things. Maybe I'm just using `ln` wrong, but this works, so 🤷.
rm -rf "${link_target_dirpath}" || true
ln -f -s "${link_source_dirpath}" "${link_target_dirpath}"

doas rcctl restart "${daemon_name}"
