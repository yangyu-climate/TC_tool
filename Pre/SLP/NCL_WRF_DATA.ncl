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
  uvmet10 = wrf_user_getvar(a,"uvmet10",time)
  var   = uvmet10(0,:,:)
  var@description = "Earth-relative 10m eastward wind"
  var@components = "eastward"
  fileO = fileSafe+"_U10.nc"
  fileS = addfile(fileO, "c")
  fileS->U10 = var
  delete(var)
;----------------------------------------------------------------------------
; Earth-relative 10m northward wind
;----------------------------------------------------------------------------
  var   = uvmet10(1,:,:)
  var@description = "Earth-relative 10m northward wind"
  var@components = "northward"
  fileO = fileSafe+"_V10.nc"
  fileS = addfile(fileO, "c")
  fileS->V10 = var
  delete(var)
  delete(uvmet10)
;----------------------------------------------------------------------------
; 2km height Pressure
;----------------------------------------------------------------------------
  varZ  = wrf_user_getvar(a,"z",time)
  varP  = wrf_user_getvar(a,"pres",time)
  height = 2000
  var   = wrf_user_intrp3d(varP,varZ,"h",height,0.,False)
  fileO = fileSafe+"_P2km.nc"
  fileS = addfile(fileO, "c")
  fileS->P2km = var
  delete(var)
;----------------------------------------------------------------------------


end do
