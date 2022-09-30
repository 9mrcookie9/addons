#!/usr/bin/with-contenv bashio

TUNNEL_NAME="$(bashio::config 'tunnelName')"
LOCAL_URL="$(bashio::config 'localUrl')"
HOSTNAME="$(bashio::config 'hostname')"
CONFIG_DIR="/data"
TUNNEL_CRED_FILE=${CONFIG_DIR}/tunnel-cert.json
TUNNEL_ORIGIN_CERT=${CONFIG_DIR}/cert.pem

export TUNNEL_CRED_FILE=${CONFIG_DIR}/tunnel-cert.json
export TUNNEL_FORCE_PROVISIONING_DNS=true

bashio::log.info "Installing the latest version of cloudflared"
curl -sL -O https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && mv cloudflared-linux-amd64 /usr/local/bin/cloudflared &&  chmod +x /usr/local/bin/cloudflared
chmod a+x /usr/local/bin/cloudflared

bashio::log.info "Checking if we have saved files on the persistent volume"

if ! bashio::fs.file_exists ${TUNNEL_ORIGIN_CERT} ; then
    bashio::log.info "Cert file does not exists. Logging in."
    cloudflared tunnel login
    bashio::log.info "Logged in, cleanup pre-existing tunnels."
    cloudflared tunnel cleanup ${TUNNEL_NAME}
    bashio::log.info "Deleting pre-existing tunnels."
    cloudflared tunnel delete ${TUNNEL_NAME}
    bashio::log.info "Tunnel ${TUNNEL_NAME} deleted."

    bashio::log.info "Backup Cloudflared cert file to persistent volume"
    cp /root/.cloudflared/cert.pem ${TUNNEL_ORIGIN_CERT}
else
    bashio::log.info "Getting Cloudflared config files from persistent volume"
    mkdir -p /root/.cloudflared
    cp ${TUNNEL_ORIGIN_CERT} /root/.cloudflared/cert.pem
fi

bashio::log.info "Starting Cloudflared tunnel"
cloudflared --name ${TUNNEL_NAME}  --url ${LOCAL_URL} --hostname ${HOSTNAME}
