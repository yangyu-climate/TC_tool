export DATA_DIR=/vortexfs1/home/yang.yu/Clark/application/WPTCS/Result/Muifa/CTRL/WRF
export SAVE_DIR=${PWD}/DATA

rm -rf ${SAVE_DIR}
mkdir  ${SAVE_DIR}

mv ${DATA_DIR}/*.nc  ${SAVE_DIR}/

