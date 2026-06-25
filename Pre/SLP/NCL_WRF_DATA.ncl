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
; 2km height Pressure
;----------------------------------------------------------------------------
  varZ  = wrf_user_getvar(a,"z",time)
  varP  = wrf_user_getvar(a,"pres",time)
  height = 2000
  var   = wrf_user_intrp3d(varP,varZ,"h",height,0.,False)
  fileO = fileI+"_P2km.nc"
  fileS = addfile(fileO, "c")
  fileS->P2km = var
  delete(var)
;----------------------------------------------------------------------------


end do
