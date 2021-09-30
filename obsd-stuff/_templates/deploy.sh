#!/usr/bin/env bash

set -euo pipefail

deploy_script_dir="$(readlink -f "$0" | xargs dirname)"; readonly deploy_script_dir

tarball_url() {
  local -r owner="$1"
  local -r repo="$2"
  local -r revision="$3"

  echo "https://github.com/${owner}/${repo}/tarball/${revision}"
}

# === BEGIN parameterization ===

revision="${1:?}"
# shellcheck disable=SC1091
. "${deploy_script_dir}/deploy_vars.sh"

echo "owner:       ${owner:?}"
echo "repo:        ${repo:?}"
echo "revision:    ${revision:?}"
echo "app_name:    ${app_name:?}"
echo "daemon_name: ${daemon_name:?}"

# === END parameterization ===

deploy_name="${app_name}-$(date +'%Y%m%d%H%M%S')"

download_dir="${HOME}/.cache/deploy/${deploy_name}"
data_basedir="${HOME}/.local/share/deploy"

mkdir -p "${download_dir}" "${data_basedir}"

cd "${download_dir}"
wget "$(tarball_url "${owner}" "${repo}" "${revision}")"
extracted_dir="$(tar -zxvf "${revision}" | head -n1)"

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
