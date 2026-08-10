load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

dir = "DATA/"
if (.not. isvar("filename")) then
  filename = "wrfout_d03*"
end if

; Process only the input links created by link_wrf_data.sh.  Derived NetCDF
; products live in the same DATA directory and otherwise match wrfout_d03*,
; causing a rerun to try opening its own *_time.nc and field products as WRF.
all_files = systemfunc("find "+dir+" -maxdepth 1 -type l -name '"+filename+"' -print | sort")
time      = -1

do i = 0,dimsizes(all_files)-1,1

  fileI = all_files(i)
  fileSafe = str_sub_str(fileI,":","_")
  print(fileI)
  a     = addfile(fileI,"r")

; Basic Variables
;----------------------------------------------------------------------------
; Time
;----------------------------------------------------------------------------
  varN  = "Times"
  var   = wrf_user_getvar(a,varN,time)
  fileO = fileSafe+"_time.nc"
  fileS = addfile(fileO, "c")
  fileS->time = var
  delete(var)  
;----------------------------------------------------------------------------
; Longitude
;----------------------------------------------------------------------------
  varN  = "lon"
  var   = wrf_user_getvar(a,varN,time)
  fileO = fileSafe+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->lon = var
  delete(var)  
;----------------------------------------------------------------------------
; Latitude
;----------------------------------------------------------------------------
  varN  = "lat"
  var   = wrf_user_getvar(a,varN,time)
  fileO = fileSafe+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->lat = var
  delete(var)  
;----------------------------------------------------------------------------
; Height
;----------------------------------------------------------------------------
  varN  = "z"
  var   = wrf_user_getvar(a,varN,time)
  var@description  = "Hight"
  var@units        = "m"
  fileO = fileSafe+"_z.nc"
  fileS = addfile(fileO, "c")
  fileS->z = var
  delete(var)
;----------------------------------------------------------------------------
; Terrain
;----------------------------------------------------------------------------
  varN  = "ter"
  var   = wrf_user_getvar(a,varN,time)
  var@description  = "Terrain hight"
  var@units        = "m"
  fileO = fileSafe+"_terrian.nc"
  fileS = addfile(fileO, "c")
  fileS->terrian = var
  delete(var)
;----------------------------------------------------------------------------
; Pressure
;----------------------------------------------------------------------------
  varN  = "pressure"
  var   = wrf_user_getvar(a,varN,time)
  var@description  = "Pressure"
  var@units        = "hPa"
  fileO = fileSafe+"_p.nc"
  fileS = addfile(fileO, "c")
  fileS->p = var
  delete(var)
;----------------------------------------------------------------------------
; Planetary Boundary Layer High
;----------------------------------------------------------------------------
  varN  = "PBLH"
  var   = wrf_user_getvar(a,varN,time)
  var   = var
  var@description  = "Planetary Boundary Layer High"
  var@units        = "m"
  fileO = fileSafe+"_pblh.nc"
  fileS = addfile(fileO, "c")
  fileS->pblh = var
  delete(var)
;----------------------------------------------------------------------------

; Thermodynamics                    
;----------------------------------------------------------------------------
; Potential Temperature
;----------------------------------------------------------------------------
  varN  = "theta"
  var   = wrf_user_getvar(a,varN,time)
  fileO = fileSafe+"_theta.nc"
  fileS = addfile(fileO, "c")
  fileS->theta = var
  delete(var)
;----------------------------------------------------------------------------
; Equivalent Potential Temperature
;----------------------------------------------------------------------------
  varN  = "eth"
  var   = wrf_user_getvar(a,varN,time)
  fileO = fileSafe+"_thetaE.nc"
  fileS = addfile(fileO, "c")
  fileS->thetaE = var
  delete(var)
;----------------------------------------------------------------------------
; Temperature [K]
;----------------------------------------------------------------------------
  varN  = "tk"
  var   = wrf_user_getvar(a,varN,time)
  fileO = fileSafe+"_tk.nc"
  fileS = addfile(fileO, "c")
  fileS->tk = var
  delete(var)
;----------------------------------------------------------------------------
; Relative Humidity
;----------------------------------------------------------------------------
  varN  = "rh"
  var   = wrf_user_getvar(a,varN,time)
  var   = var
  var@description  = "Relative Humidity"
  var@units        = "%"
  fileO = fileSafe+"_rh.nc"
  fileS = addfile(fileO, "c")
  fileS->rh = var
  delete(var)
;----------------------------------------------------------------------------
; Potential Vorticity
;----------------------------------------------------------------------------
  varN  = "pvo"
  var   = wrf_user_getvar(a,varN,time)
  var@description  = "Potential Vorticity"
  var@units        = "PVU"
  fileO = fileSafe+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->pvo = var
  delete(var)
;----------------------------------------------------------------------------
; Diadatic Heating
;----------------------------------------------------------------------------
  varN  = "H_DIABATIC"
  var   = wrf_user_getvar(a,varN,time)
  var   = var*24*60*60
  var@description  = "Microphysics Latent Heating"
  var@units        = "K day-1"
  fileO = fileSafe+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->H_DIABATIC = var
  delete(var)
;----------------------------------------------------------------------------
; Theta Tendency due to Radiation
;----------------------------------------------------------------------------
  varN  = "RTHRATEN"
  var   = wrf_user_getvar(a,varN,time)
  var   = var*24*60*60
  var@description  = "Theta Tendency due to Radiation"
  var@units        = "K day-1"
  fileO = fileSafe+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->RTHRATEN = var
  delete(var)
;----------------------------------------------------------------------------
; Theta Tendency due to Longwave Radiation
;----------------------------------------------------------------------------
  varN  = "RTHRATLW"
  var   = wrf_user_getvar(a,varN,time)
  var   = var*24*60*60
  var@description  = "Theta Tendency due to Longwave Radiation"
  var@units        = "K day-1"
  fileO = fileSafe+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->RTHRATLW = var
  delete(var)
;----------------------------------------------------------------------------
; Theta Tendency due to Shortwave Radiation
;----------------------------------------------------------------------------
  varN  = "RTHRATSW"
  var   = wrf_user_getvar(a,varN,time)
  var   = var*24*60*60
  var@description  = "Theta Tendency due to Shortwave Radiation"
  var@units        = "K day-1"
  fileO = fileSafe+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->RTHRATSW = var
  delete(var)
;----------------------------------------------------------------------------
; Water Vapor Mixing Ratio
;----------------------------------------------------------------------------
  varN  = "QVAPOR"
  var   = wrf_user_getvar(a,varN,time)
  var   = var*1000
  var@description  = "Water vapor mixing ratio"
  var@units        = "g kg-1"
  fileO = fileSafe+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->QVAPOR = var
  delete(var)
;----------------------------------------------------------------------------
; Cloud Water Mixing Ratio
;----------------------------------------------------------------------------
  varN  = "QCLOUD"
  var   = wrf_user_getvar(a,varN,time)
  var   = var*1000
  var@description  = "Cloud water mixing ratio"
  var@units        = "g kg-1"
  fileO = fileSafe+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->QCLOUD = var
  delete(var)
;----------------------------------------------------------------------------
; Rain Water Mixing Ratio
;----------------------------------------------------------------------------
  varN  = "QRAIN"
  var   = wrf_user_getvar(a,varN,time)
  var   = var*1000
  var@description  = "Rain water mixing ratio"
  var@units        = "g kg-1"
  fileO = fileSafe+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->QRAIN = var
  delete(var)
;----------------------------------------------------------------------------
; Ice Mixing Ratio
;----------------------------------------------------------------------------
  varN  = "QICE"
  var   = wrf_user_getvar(a,varN,time)
  var   = var*1000
  var@description  = "Ice mixing ratio"
  var@units        = "g kg-1"
  fileO = fileSafe+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->QICE = var
  delete(var)
;----------------------------------------------------------------------------
; Snow Mixing Ratio
;----------------------------------------------------------------------------
  varN  = "QSNOW"
  var   = wrf_user_getvar(a,varN,time)
  var   = var*1000
  var@description  = "Snow mixing ratio"
  var@units        = "g kg-1"
  fileO = fileSafe+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->QSNOW = var
  delete(var)
;----------------------------------------------------------------------------
; Graupel Mixing Ratio
;----------------------------------------------------------------------------
  varN  = "QGRAUP"
  var   = wrf_user_getvar(a,varN,time)
  var   = var*1000
  var@description  = "Graupel mixing ratio"
  var@units        = "g kg-1"
  fileO = fileSafe+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->QGRAUP = var
  delete(var)
;----------------------------------------------------------------------------
; Dry Air Density
;----------------------------------------------------------------------------
  varP  = wrf_user_getvar(a,"pres",time)
  varT  = wrf_user_getvar(a,"tk"  ,time)
  varR  = 287.05
  var   = varP/(varT*varR)
  var@description  = "Density of dry air"
  var@units        = "kg m-3"
  fileO = fileSafe+"_rhoD.nc"
  fileS = addfile(fileO, "c")
  fileS->rhoD = var
  delete(varP)
  delete(varT)
  delete(varR)
  delete(var)
;----------------------------------------------------------------------------
; Density
;----------------------------------------------------------------------------
  varN  = "ALT"
  var   = wrf_user_getvar(a,varN,time)
  var   = 1/var
  var@description  = "Density"
  var@units        = "kg m-3"
  fileO = fileSafe+"_rho.nc"
  fileS = addfile(fileO, "c")
  fileS->rho = var
  delete(var)
;----------------------------------------------------------------------------
; Sea Surface Temperature
;----------------------------------------------------------------------------
  varN  = "SST"
  var   = wrf_user_getvar(a,varN,time)
  fileO = fileSafe+"_sst.nc"
  fileS = addfile(fileO, "c")
  fileS->sst = var
  delete(var)
;----------------------------------------------------------------------------
;  Short Wave Radiation
;----------------------------------------------------------------------------
  varN  = "SWDNB"
  varDN = wrf_user_getvar(a,varN,time)
  varN  = "SWUPB"
  varUP = wrf_user_getvar(a,varN,time)
  var   = varDN-varUP
  var@long_name  = "Short Wave Radiation (downward positive)"
  var@units      = "W m-2"
  fileO = fileSafe+"_gsw.nc"
  fileS = addfile(fileO, "c")
  fileS->gsw = var
  delete(varDN)
  delete(varUP)
  delete(var)
;----------------------------------------------------------------------------
; Long Wave Radiation
;----------------------------------------------------------------------------
  varN  = "LWDNB"
  varDN = wrf_user_getvar(a,varN,time)
  varN  = "LWUPB"
  varUP = wrf_user_getvar(a,varN,time)
  var   = varUP-varDN
  var@long_name  = "Long Wave Radiation (upward positive)"
  var@units      = "W m-2"
  fileO = fileSafe+"_glw.nc"
  fileS = addfile(fileO, "c")
  fileS->glw = var
  delete(varDN)
  delete(varUP)
  delete(var)
;----------------------------------------------------------------------------
; Latent Heat Flux
;----------------------------------------------------------------------------
  varN  = "LH"
  var   = wrf_user_getvar(a,varN,time)
  var@long_name  = "Latent Heat Flux (upward positive)"
  var@units      = "W m-2"
  fileO = fileSafe+"_lh.nc"
  fileS = addfile(fileO, "c")
  fileS->lh = var
  delete(var)
;----------------------------------------------------------------------------
; Sensible Heat Flux
;----------------------------------------------------------------------------
  varN  = "HFX"
  var   = wrf_user_getvar(a,varN,time)
  var@long_name  = "Sensible Heat Flux (upward positive)"
  var@units      = "W m-2"
  fileO = fileSafe+"_hfx.nc"
  fileS = addfile(fileO, "c")
  fileS->hfx = var
  delete(var)
;----------------------------------------------------------------------------

; Dynamics
;----------------------------------------------------------------------------
; Omega
;----------------------------------------------------------------------------
  varN  = "omg"
  var   = wrf_user_getvar(a,varN,time)
  var@description  = "Pressure vertical velocity"
  var@units        = "Pa s-1"
  fileO = fileSafe+"_omega.nc"
  fileS = addfile(fileO, "c")
  fileS->omega = var
  delete(var)
;----------------------------------------------------------------------------
; Absolute Vorticity
;----------------------------------------------------------------------------
  varN  = "avo"
  var   = wrf_user_getvar(a,varN,time)
  var   = var/10^5
  var@description  = "Absolute Vorticity"
  var@units        = "s-1"
  fileO = fileSafe+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->avo = var
  delete(var)
;----------------------------------------------------------------------------
; Coriolis sine latitude term
;----------------------------------------------------------------------------
  varN  = "F"
  var   = wrf_user_getvar(a,varN,time)
  var@description  = "Coriolis sine latitude term"
  var@units        = "s-1"
  fileO = fileSafe+"_f.nc"
  fileS = addfile(fileO, "c")
  fileS->f = var
  delete(var)
;----------------------------------------------------------------------------
; Earth-relative horizontal wind
;----------------------------------------------------------------------------
  ; ua/va are unstaggered WRF-grid-relative winds.  Rotate them explicitly
  ; with the map factors so the MATLAB diagnostics receive east/north winds.
  ua = wrf_user_getvar(a,"ua",time)
  va = wrf_user_getvar(a,"va",time)
  cosalpha = a->COSALPHA(0,:,:)
  sinalpha = a->SINALPHA(0,:,:)
  nDim = dimsizes(dimsizes(ua))
  cosalpha_wind = conform_dims(dimsizes(ua),cosalpha,(/nDim-2,nDim-1/))
  sinalpha_wind = conform_dims(dimsizes(ua),sinalpha,(/nDim-2,nDim-1/))
  var   = ua*cosalpha_wind - va*sinalpha_wind
  var@description  = "Earth-relative eastward wind on mass points"
  var@units        = "m s-1"
  var@components    = "eastward"
  fileO = fileSafe+"_u.nc"
  fileS = addfile(fileO, "c")
  fileS->u = var
  delete(var)
;----------------------------------------------------------------------------
; Earth-relative northward wind
;----------------------------------------------------------------------------
  var   = ua*sinalpha_wind + va*cosalpha_wind
  var@description  = "Earth-relative northward wind on mass points"
  var@units        = "m s-1"
  var@components    = "northward"
  fileO = fileSafe+"_v.nc"
  fileS = addfile(fileO, "c")
  fileS->v = var
  delete(var)
  delete(ua)
  delete(va)
  delete(cosalpha)
  delete(sinalpha)
  delete(cosalpha_wind)
  delete(sinalpha_wind)
;----------------------------------------------------------------------------
; W Wind
;----------------------------------------------------------------------------
  varN  = "wa"
  var   = wrf_user_getvar(a,varN,time)
  var@description  = "W component of wind on mass points"
  var@units        = "m s-1"
  fileO = fileSafe+"_w.nc"
  fileS = addfile(fileO, "c")
  fileS->w = var
  delete(var)
;----------------------------------------------------------------------------
; Sea level pressure
;----------------------------------------------------------------------------
  varN  = "slp"
  var   = wrf_user_getvar(a,varN,time)
  fileO = fileSafe+"_slp.nc"
  fileS = addfile(fileO, "c")
  fileS->slp = var
  delete(var)
;----------------------------------------------------------------------------
; Earth-relative 10m eastward wind
;----------------------------------------------------------------------------
  u10 = wrf_user_getvar(a,"U10",time)
  v10 = wrf_user_getvar(a,"V10",time)
  cosalpha = a->COSALPHA(0,:,:)
  sinalpha = a->SINALPHA(0,:,:)
  nDim = dimsizes(dimsizes(u10))
  cosalpha_wind = conform_dims(dimsizes(u10),cosalpha,(/nDim-2,nDim-1/))
  sinalpha_wind = conform_dims(dimsizes(u10),sinalpha,(/nDim-2,nDim-1/))
  var   = u10*cosalpha_wind - v10*sinalpha_wind
  var@description = "Earth-relative 10m eastward wind"
  var@components = "eastward"
  fileO = fileSafe+"_U10.nc"
  fileS = addfile(fileO, "c")
  fileS->U10 = var
  delete(var)
;----------------------------------------------------------------------------
; Earth-relative 10m northward wind
;----------------------------------------------------------------------------
  var   = u10*sinalpha_wind + v10*cosalpha_wind
  var@description = "Earth-relative 10m northward wind"
  var@components = "northward"
  fileO = fileSafe+"_V10.nc"
  fileS = addfile(fileO, "c")
  fileS->V10 = var
  delete(var)
  delete(u10)
  delete(v10)
  delete(cosalpha)
  delete(sinalpha)
  delete(cosalpha_wind)
  delete(sinalpha_wind)
;----------------------------------------------------------------------------

end do
