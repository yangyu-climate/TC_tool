rm -rf running.log
rm -rf running.err
rm -rf Data
rm -rf Fig
#rm -rf Result
nohup matlab -nodisplay -nosplash -nodesktop < Run.m 1>running.log 2>running.err &
