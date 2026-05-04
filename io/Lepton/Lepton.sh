#!/usr/bin/env bash
# Lepton — Bitsy coinage prototype, deployed via Nick's deployer.
set -euo pipefail
source "$(git rev-parse --show-toplevel)/lib/crucible/script/lib.sh"

proto_predict Lepton 0x000000000000000000000000000000000000000000000000000000002b3fbfee
