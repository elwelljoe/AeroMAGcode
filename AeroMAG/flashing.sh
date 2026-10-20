#!/usr/bin/env bash

#run nano flashing.sh in the terminal to activate this bash file
#this file helps automate the flashing of the ulx3s using yosys and oss-cad-suite

set -euo pipefail

name=${1%.v}

yosys -q -p "synth_ecp5 -json $name.json" "$1"
nextpnr-ecp5 --quiet --85k --package CABGA381 --json "$name.json" --lpf ulx3s_v20.lpf --textcfg "$name.config"
ecppack --compress "$name.config" "$name.bit"