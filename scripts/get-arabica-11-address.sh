#!/bin/bash
cd ~/.celestia-light-arabica-11
cel-key list --node.type light --keyring-backend test --p2p.network arabica --output json |  sed '1d' | jq -r '.[0].address'