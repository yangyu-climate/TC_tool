clc
clear all
close all

run_dir = ['../'];
addpath([run_dir,'/ncl_color'])
addpath([run_dir,'/ncl_color/ncl_rgb'])

figure
mesh(peaks)

colorbar
% color = ncl_colormap('CBR_coldhot',10);
color = ncl_colormap('precip2_17lev',10);
colormap(color)
