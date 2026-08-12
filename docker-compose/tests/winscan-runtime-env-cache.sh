#!/bin/sh
set -eu

outer_config="${1:-docker-compose/proxy/winscan.co.conf}"
inner_config="${2:-docker-compose/proxy/explorer.conf.template}"

for config in "$outer_config" "$inner_config"; do
  grep -Fq 'location = /assets/envs.js {' "$config"
  grep -Eq 'proxy_hide_header[[:space:]]+Cache-Control;' "$config"
  grep -Fq 'add_header Cache-Control "no-store, no-cache, must-revalidate" always;' "$config"
  grep -Fq 'add_header Pragma "no-cache" always;' "$config"
  grep -Fq 'add_header Expires "0" always;' "$config"
done
