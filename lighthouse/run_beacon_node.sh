#!/bin/env bash

set -exu -o pipefail

: "${EXECUTION_NODE_URL:-}"
: "${VERBOSITY:-info}"

DATADIR=/chaindata
VALIDATOR_COUNT=4

# wait for the genesis service to start
RETRIES=60
i=0
until curl --silent --fail "genesis-generator:8000";
do
    sleep 1
    if [ $i -eq $RETRIES ]; then
        echo 'Timed out waiting for genesis generator'
        exit 1
    fi
    echo 'Waiting for genesis generator...'
    ((i=i+1))
done

EXTERNAL_IP=$(ip addr show eth0 | grep inet | awk '{ print $2 }' | cut -d '/' -f1)
NETWORK_PORT=9000
HTTP_PORT=5052

lighthouse \
	beacon_node \
	--debug-level info \
	--datadir "$DATADIR" \
	--purge-db \
	--execution-endpoint "$EXECUTION_NODE_URL"  \
	--execution-jwt $TESTNET_DIR/cl/jwtsecret \
	--testnet-dir $TESTNET_DIR/custom_config_data \
	--port $NETWORK_PORT \
	--http \
	--http-port $HTTP_PORT \
	--http-address 0.0.0.0 \
	--http-allow-sync-stalled \
	--enable-private-discovery \
	--enr-address $EXTERNAL_IP \
	--enr-udp-port $NETWORK_PORT \
	--enr-tcp-port $NETWORK_PORT \
	--disable-enr-auto-update \
	--subscribe-all-subnets \
	--trusted-setup-file $TESTNET_DIR/trusted_setup.txt \
	--disable-packet-filter $@
