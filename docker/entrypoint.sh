#!/usr/bin/env sh

set -e

# function that prints info message, if TUNNEL_LOGLEVEL is debug or info
info() {
  echo "${TUNNEL_LOGLEVEL}" | grep -q -E '^(debug|info)$' || return 0
  formatted_date=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
  echo "$formatted_date INF ${1}"
}

# function that prints warn message, if TUNNEL_LOGLEVEL is debug, info, warn and error
error() {
  echo "${TUNNEL_LOGLEVEL}" | grep -q -E '^(debug|info|warn|error)$' || return 0
  formatted_date=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
  echo "$formatted_date ERR ${1}"
}

# function that prints fatal message and exits
fatal() {
  formatted_date=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
  echo >&2 "$formatted_date FAT ${1}"
  exit 1
}

if [ -z "${TUNNEL_HOSTNAME}" ]; then
  fatal "You need to specify TUNNEL_HOSTNAME"
fi

if [ -z "${S3_CERT_PEM}" ]; then
  fatal "You need to specify S3_CERT_PEM"
fi

if [ -z "${TUNNEL_URL}" ]; then
  fatal "You need to specify TUNNEL_URL"
fi

aws s3 cp "${S3_CERT_PEM}" /etc/cloudflared/

# Make sure TUNNEL_LOGLEVEL is valid
echo "${TUNNEL_LOGLEVEL}" | grep -q -E '^(debug|info|warn|error|fatal)$' || fatal $? "TUNNEL_LOGLEVEL must be debug|info|warn|error|fatal"

# Prevent message about missing config file.
if [ ! -f /etc/cloudflared/config.yml ]; then
  info "/etc/cloudflared/config.yml not found autogenerating one"
  echo "---" >/etc/cloudflared/config.yml
fi

derived_tunnel_name=$(echo "${TUNNEL_HOSTNAME}" | sed "s,^.*://,,g" | tr '[:upper:]' '[:lower:]')
unset TUNNEL_HOSTNAME

cloudflared --loglevel 'error' tunnel token "${derived_tunnel_name}" > /tmp/creds.json || exit_code=$?
if [ -z "${exit_code}" ]; then
  tunnel_id=$(base64 -d < /tmp/creds.json | jq -r '.t')
  base64 -d < /tmp/creds.json | jq '.["AccountTag"] = .a | .["TunnelID"] = .t | .["TunnelSecret"] = .s' > /etc/cloudflared/"${tunnel_id}".json
fi

if [ -n "${exit_code}" ]; then
  info "Creating new named tunnel '${derived_tunnel_name}'"
  cloudflared --loglevel 'error' tunnel create "${derived_tunnel_name}" 1>/dev/null

  info "Routing dns from '${derived_tunnel_name}' to tunnel"
  cloudflared --loglevel 'error' tunnel route dns --overwrite-dns "${derived_tunnel_name}" "${derived_tunnel_name}"
fi

exec "cloudflared" "tunnel" "run" "${derived_tunnel_name}"
