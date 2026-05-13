#!/usr/bin/env bash
# Lepton — Bitsy coinage prototype, deployed via Nick's deployer.
set -euo pipefail
source "$(git rev-parse --show-toplevel)/lib/crucible/script/proto.sh"

mask=0xfff000000000000000000000000000000000ffff
target=0x1eb000000000000000000000000000000000e300
proto_predict Lepton 0x00000000000000000000000000000000000000000000000000000000053d5d8b
