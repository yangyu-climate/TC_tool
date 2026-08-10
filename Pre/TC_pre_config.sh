#!/usr/bin/env sh
# Shared preprocessing parameters for TC_tool.
# Set source_dir once before running Pre/SLP, Pre/PHY, or Pre/BGT.
# Each module's Run.sh creates DATA/ as symbolic links to these WRF files.

source_dir="/path/to/your/WRF/output/"
filename="wrfout_d03*"
