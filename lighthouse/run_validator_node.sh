#!/bin/sh

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

lighthouse \
	vc \
	--validators-dir /data/assigned_data/keys \
	--secrets-dir /data/assigned_data/secrets \
	--testnet-dir /data/custom_config_data \
	--init-slashing-protection \
	--beacon-nodes http://lighthouse-beacon-node:5052 \
  --suggested-fee-recipient 0x690B9A9E9aa1C9dB991C7721a92d351Db4FaC990