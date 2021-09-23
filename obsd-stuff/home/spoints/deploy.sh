#!/usr/bin/env bash

set -euo pipefail

owner='awseward'
repo='spiderman-points'
rev="${1:-main}"

deploy_name="spoints-$(date +'%Y%m%d%H%M%S')"

download_dir="${HOME}/.cache/deploy/${deploy_name}"
data_basedir="${HOME}/.local/share/deploy"

mkdir -p "${download_dir}" "${data_basedir}"

cd "${download_dir}"
wget "https://github.com/${owner}/${repo}/tarball/${rev}"
extracted_dir="$(tar -zxvf "${rev}" | head -n1)"

link_source_dirpath="${data_basedir}/${deploy_name}"
link_target_dirpath="${HOME}/spoints"

mv "${extracted_dir}" "${link_source_dirpath}"

cd "${link_source_dirpath}"
bundle config set --local deployment 'true'
bundle install

# I've found if you don't delete this first, it tends to start doing weird
# things. Maybe I'm just using `ln` wrong, but this works, so 🤷.
rm -rf "${link_target_dirpath}" || true

ln -f -s "${link_source_dirpath}" "${link_target_dirpath}"

doas rcctl restart spointsd
