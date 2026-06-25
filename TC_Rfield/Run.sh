rm -rf running.log
rm -rf running.err
nohup matlab -nodisplay -nosplash -nodesktop < Run.m 1>running.log 2>running.err &
