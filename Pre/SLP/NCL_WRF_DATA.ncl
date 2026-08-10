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
  ; U10/V10 are WRF-grid-relative; rotate explicitly with map factors.
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
