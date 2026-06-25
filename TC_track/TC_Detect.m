clear
clc

warning off
Run_dir = ['../'];
addpath(Run_dir);
start
cfg = TC_track_config;
Data_dir   = cfg.Input_dir;
Save_nam   = cfg.Save_nam;
head_nam   = cfg.Head_nam;
resolution = cfg.resolution;
dR         = cfg.dR;
dN         = ceil(dR/resolution);
TCR        = cfg.TCR;
TWR        = cfg.TWR;
TLM        = ceil(TCR/resolution);
TLN        = ceil(TWR/resolution);


save_dir = [pwd,'/Data'];
mkdir(save_dir)
Fig_dir  = [pwd,'/Fig'];
mkdir(Fig_dir)
       
file_name = [head_nam,'*_slp.nc'];        
filename  = dir([Data_dir,'/',file_name]);
 
count = 0;
if ~isempty(filename)
    for N = 1:length(filename)
        file_name = filename(N).name;
        file_name = file_name(1:end-7);
        
        fileN     = [Data_dir,'/',file_name,'_time.nc'];
        time      = ncread(fileN,'time')';
        year      = str2num(time(1:4));
        month     = str2num(time(6:7));
        day       = str2num(time(9:10));
        hour      = str2num(time(12:13));
        minu      = str2num(time(15:16));
        seco      = str2num(time(18:19));
        T         = datenum([year,month,day,hour,minu,seco]);
        
        disp([' '])
        disp(['WRF output file: ',file_name])
        fileN     = [Data_dir,'/',file_name,'_lon.nc'];
        lon       = ncread(fileN,'lon');
        fileN     = [Data_dir,'/',file_name,'_lat.nc'];
        lat       = ncread(fileN,'lat');
        fileN     = [Data_dir,'/',file_name,'_slp.nc'];
        slp       = ncread(fileN,'slp');
        disp(['Load SLP data from: ',fileN])
        fileN     = [Data_dir,'/',file_name,'_U10.nc'];
        u10       = ncread(fileN,'U10');
        disp(['Load U10 data from: ',fileN])
        fileN     = [Data_dir,'/',file_name,'_V10.nc'];
        v10       = ncread(fileN,'V10');
        disp(['Load V10 data from: ',fileN])
        swd       = sqrt(u10.^2   +v10.^2);
        fileN     = [Data_dir,'/',file_name,'_P2km.nc'];
        P2km      = ncread(fileN,'P2km');
        disp(['Load P2km data from: ',fileN])
 
        if dN>1
            slp = running_mean_2D(slp,dN);
            swd = running_mean_2D(swd,dN);
        end

        [slp_lon,slp_lat,slp_p,slp_w,slp_tw_lon,slp_tw_lat] = TC_center_CIM(lon,lat,slp ,swd,TLM,TLN,resolution);
        [tc_lon,tc_lat,p2km_p,tc_w,tw_lon,tw_lat] = TC_center_CIM(lon,lat,P2km,swd,TLM,TLN,resolution);
        tc_p = NaN*ones(size(tc_lon));
        if ~isnan(nanmean(slp_p))
            loc_slp_min = find(slp_p==nanmin(slp_p));
            loc_slp_min = min(loc_slp_min);
            tc_p(:) = slp_p(loc_slp_min);
        end
        
        T_nam     = [file_name(12:end)];
        Save_file = [Save_nam,'_',T_nam,'.mat'];
        save([save_dir,'/',Save_file],...
            'T','tc_lon','tc_lat','tc_p','tc_w',...
            'lon','lat','slp','swd','P2km',...
            'tw_lon','tw_lat',...
            'p2km_p',...
            'slp_lon','slp_lat','slp_p','slp_w','slp_tw_lon','slp_tw_lat')
        
        figure;
        pcolor(lon,lat,swd)
        caxis([0 30])
        shading flat
        hold on
        contour(lon,lat,slp,[910:2:1100])
        plot(tc_lon,tc_lat,'*r')
        plot(tw_lon,tw_lat,'*k')
        colorbar
        colormap(jet)
        picture=[Fig_dir,'/',Save_nam,'_',T_nam,'.jpg'];
        set(gcf,'color','white','paperpositionmode','auto');
        saveas(gcf,picture);
        close all
        
    end
end
