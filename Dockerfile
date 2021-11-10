FROM debian:stable as builder

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get -q -y update && \
    apt-get -q -y install wget \
                          curl \
                          git \
                          unzip \
                          build-essential \
                          golang && \
    apt-get -q -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    \
    git clone https://github.com/binance-chain/bsc /bsc && \
    cd /bsc && \
    make geth && \
    cd / && \
    \
    wget   $(curl -s https://api.github.com/repos/binance-chain/bsc/releases/latest |grep browser_ |grep mainnet |cut -d\" -f4) && \
    wget   $(curl -s https://api.github.com/repos/binance-chain/bsc/releases/latest |grep browser_ |grep testnet |cut -d\" -f4) && \
    \
    cp /bsc/build/bin/geth /usr/bin/geth && \
    tar cvf /transfer.tar /usr/bin/geth /*.zip

FROM debian:stable

ENV NETWORK=main
COPY --from=builder /transfer.tar /transfer.tar

RUN cd / \
 && tar xvf /transfer.tar \
 && rm /transfer.tar && \
 \
 export DEBIAN_FRONTEND=noninteractive && \
 apt-get -q -y update && \
 apt-get -q -y install unzip && \
 apt-get -q -y clean && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# NODE P2P
EXPOSE 30311/udp
EXPOSE 30311/tcp

# pprof / metrics
EXPOSE 6060/tcp

# HTTP based JSON RPC API
EXPOSE 8545/tcp
# WebSocket based JSON RPC API
EXPOSE 8546/tcp
# GraphQL API
EXPOSE 8547/tcp


CMD sh -xc "cd /data; [ ! -f '/data/genesis.json' ] && unzip /$NETWORK'net.zip' && \
 geth --datadir . init genesis.json && sed -i '/^HTTP/d' ./config.toml; \
 exec geth --config ./config.toml --datadir .  --ipcpath /node/geth.ipc  --diffsync  \
 --pprof --pprof.addr 0.0.0.0 --metrics \
 --http --http.api eth,net,web3,txpool,parlia --http.addr 0.0.0.0 --http.port 8545 --http.corsdomain '*' --http.vhosts '*' \
 --ws --ws.api eth,net,web3 --ws.origins '*' --ws.addr 0.0.0.0 --ws.port 8546 \
 --graphql --graphql.corsdomain '*' --graphql.vhosts '*' \
 --cache 8000 --rpc.allow-unprotected-txs  --txlookuplimit 0 "
