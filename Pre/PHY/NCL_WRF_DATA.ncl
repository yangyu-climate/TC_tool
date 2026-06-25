load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

dir  = "/vortexfs1/home/yang.yu/Clark/application/WPTCS/Result/Muifa/CTRL/WRF/"
filename  = "wrfout_d03*"

all_files = systemfunc("ls "+dir+filename)
time      = -1

do i = 0,dimsizes(all_files)-1,1

  fileI = all_files(i)
  print(fileI)
  a     = addfile(fileI,"r")

; Basic Variables
;----------------------------------------------------------------------------
; Time
;----------------------------------------------------------------------------
  varN  = "Times"
  var   = wrf_user_getvar(a,varN,time)
  fileO = fileI+"_time.nc"
  fileS = addfile(fileO, "c")
  fileS->time = var
  delete(var)  
;----------------------------------------------------------------------------
; Longitude
;----------------------------------------------------------------------------
  varN  = "lon"
  var   = wrf_user_getvar(a,varN,time)
  fileO = fileI+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->lon = var
  delete(var)  
;----------------------------------------------------------------------------
; Latitude
;----------------------------------------------------------------------------
  varN  = "lat"
  var   = wrf_user_getvar(a,varN,time)
  fileO = fileI+"_"+varN+".nc"
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
  fileO = fileI+"_z.nc"
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
  fileO = fileI+"_terrian.nc"
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
  fileO = fileI+"_p.nc"
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
  fileO = fileI+"_pblh.nc"
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
  fileO = fileI+"_theta.nc"
  fileS = addfile(fileO, "c")
  fileS->theta = var
  delete(var)
;----------------------------------------------------------------------------
; Equivalent Potential Temperature
;----------------------------------------------------------------------------
  varN  = "eth"
  var   = wrf_user_getvar(a,varN,time)
  fileO = fileI+"_thetaE.nc"
  fileS = addfile(fileO, "c")
  fileS->thetaE = var
  delete(var)
;----------------------------------------------------------------------------
; Temperature [K]
;----------------------------------------------------------------------------
  varN  = "tk"
  var   = wrf_user_getvar(a,varN,time)
  fileO = fileI+"_tk.nc"
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
  fileO = fileI+"_rh.nc"
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
  fileO = fileI+"_"+varN+".nc"
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
  fileO = fileI+"_"+varN+".nc"
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
  fileO = fileI+"_"+varN+".nc"
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
  fileO = fileI+"_"+varN+".nc"
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
  fileO = fileI+"_"+varN+".nc"
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
  fileO = fileI+"_"+varN+".nc"
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
  fileO = fileI+"_"+varN+".nc"
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
  fileO = fileI+"_"+varN+".nc"
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
  fileO = fileI+"_"+varN+".nc"
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
  fileO = fileI+"_"+varN+".nc"
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
  fileO = fileI+"_"+varN+".nc"
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
  fileO = fileI+"_rhoD.nc"
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
  fileO = fileI+"_rho.nc"
  fileS = addfile(fileO, "c")
  fileS->rho = var
  delete(var)
;----------------------------------------------------------------------------
; Sea Surface Temperature
;----------------------------------------------------------------------------
  varN  = "SST"
  var   = wrf_user_getvar(a,varN,time)
  fileO = fileI+"_sst.nc"
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
  fileO = fileI+"_gsw.nc"
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
  fileO = fileI+"_glw.nc"
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
  fileO = fileI+"_lh.nc"
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
  fileO = fileI+"_hfx.nc"
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
  fileO = fileI+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->omg = var
  delete(var)
;----------------------------------------------------------------------------
; Absolute Vorticity
;----------------------------------------------------------------------------
  varN  = "avo"
  var   = wrf_user_getvar(a,varN,time)
  var   = var/10^5
  var@description  = "Absolute Vorticity"
  var@units        = "s-1"
  fileO = fileI+"_"+varN+".nc"
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
  fileO = fileI+"_f.nc"
  fileS = addfile(fileO, "c")
  fileS->f = var
  delete(var)
;----------------------------------------------------------------------------
; U Wind
;----------------------------------------------------------------------------
  varN  = "ua"
  var   = wrf_user_getvar(a,varN,time)
  var@description  = "U component of wind on mass points"
  var@units        = "m s-1"
  fileO = fileI+"_u.nc"
  fileS = addfile(fileO, "c")
  fileS->u = var
  delete(var)
;----------------------------------------------------------------------------
; V Wind
;----------------------------------------------------------------------------
  varN  = "va"
  var   = wrf_user_getvar(a,varN,time)
  var@description  = "V component of wind on mass points"
  var@units        = "m s-1"
  fileO = fileI+"_v.nc"
  fileS = addfile(fileO, "c")
  fileS->v = var
  delete(var)
;----------------------------------------------------------------------------
; W Wind
;----------------------------------------------------------------------------
  varN  = "wa"
  var   = wrf_user_getvar(a,varN,time)
  var@description  = "W component of wind on mass points"
  var@units        = "m s-1"
  fileO = fileI+"_w.nc"
  fileS = addfile(fileO, "c")
  fileS->w = var
  delete(var)
;----------------------------------------------------------------------------
; Sea level pressure
;----------------------------------------------------------------------------
  varN  = "slp"
  var   = wrf_user_getvar(a,varN,time)
  fileO = fileI+"_slp.nc"
  fileS = addfile(fileO, "c")
  fileS->slp = var
  delete(var)
;----------------------------------------------------------------------------
; 10m U component of wind on mass points
;----------------------------------------------------------------------------
  varN  = "U10"
  var   = wrf_user_getvar(a,varN,time)
  fileO = fileI+"_U10.nc"
  fileS = addfile(fileO, "c")
  fileS->U10 = var
  delete(var)
;----------------------------------------------------------------------------
; 10m V component of wind on mass points
;----------------------------------------------------------------------------
  varN  = "V10"
  var   = wrf_user_getvar(a,varN,time)
  fileO = fileI+"_V10.nc"
  fileS = addfile(fileO, "c")
  fileS->V10 = var
  delete(var)
;----------------------------------------------------------------------------

end do
