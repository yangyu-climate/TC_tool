#!/usr/bin/env sh
# Shared preprocessing parameters for TC_tool.
# Set source_dir once before running Pre/SLP, Pre/PHY, or Pre/BGT.
# Each preprocessing module's Sub.sh creates DATA/ symbolic links to these WRF files.

source_dir="/path/to/your/WRF/output/"
filename="wrfout_d03*"
