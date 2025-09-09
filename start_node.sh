#!/bin/bash
set -e
. .env

# Init chain if not done
if [ ! -d /root/.ethereum/geth ]; then
  geth init --datadir /root/.ethereum genesis.json
fi

# Start geth in background
geth --networkid 999 \
  --datadir /root/.ethereum \
  --http --http.addr 0.0.0.0 --http.port 9636 \
  --http.api personal,eth,net,web3,miner \
  --allow-insecure-unlock \
  --unlock $COINBASE \
  --password /app/password.txt \
  --mine --miner.etherbase=$COINBASE --miner.threads=1 \
  --http.corsdomain="*" \
  --http.vhosts="*" \
  --syncmode 'full' &

# Wait for Geth to boot
sleep 10

# Start FastAPI with Uvicorn
exec uvicorn app.main:app --host 0.0.0.0 --port 8000
