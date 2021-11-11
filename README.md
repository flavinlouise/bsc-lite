# Binance Smart Chain

Binance Smart Chain Fullnode.

based on 

## Changelogs


## Info

This is a Binance Smart Chain Fullnode Container running on `_/debian`.

For more see: https://docs.binance.org/smart-chain/developer/fullnode.html

## Environment variables and defaults

### notice

* --ipcpath /node/geth.ipc    
ipc path must not within external SSD if MacOS
* --diffsync new mode in geth 1.13


For more see: https://geth.ethereum.org/docs/interface/command-line-options

### Samba

*  __NETWORK__
    * _default:_ `main`
    * can be set to `main` or `test`
    * let's you choose which binance network to use
    * with existing initialized persistent volume changing has no effect

### Volumes

* __/data__
    * data volume to store all the blockchain / binance smart chain data
    * will be initialized the first time with configured network genesis

### Ports

* 6060 `tcp`
    * pprof / metrics
* 8545 `tcp`
    * HTTP based JSON RPC API
* 8546 `tcp`
    * WebSocket based JSON RPC API
* 30311 `udp` `tcp`
    * Node P2P

## Example docker-compose.yml

```
version: '3'
 
services:
  bsc:
    image: xxx/bsc-lite
    restart: always
    environment:
      NETWORK: main
    volumes:
      - ./data:/data
    ports:
      - "127.0.0.1:6060:6060"
      - "127.0.0.1:8545:8545"
      - "127.0.0.1:8546:8546"
      - "30311:30311"
```
