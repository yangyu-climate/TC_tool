#!/bin/sh

matlab -nodesktop -nosplash -r "try, Run, catch ME, disp(getReport(ME,'extended')), exit(1), end, exit(0)"
