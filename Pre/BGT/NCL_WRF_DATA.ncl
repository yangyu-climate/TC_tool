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
; Pressure vertical velocity
;----------------------------------------------------------------------------
  ; NCL WRFUserARW names this diagnostic "omg". Its earlier water-vapour
  ; bug was fixed in NCL 6.4.0; retain omega as the exported interface name.
  varN  = "omg"
  var   = wrf_user_getvar(a,varN,time)
  var@description  = "Pressure vertical velocity"
  var@units        = "Pa s-1"
  fileO = fileSafe+"_omega.nc"
  fileS = addfile(fileO, "c")
  fileS->omega = var
  delete(var)
;----------------------------------------------------------------------------
; Sea-level pressure (used for the instantaneous storm centre)
;----------------------------------------------------------------------------
  varN  = "slp"
  var   = wrf_user_getvar(a,varN,time)
  var@description = "Sea level pressure"
  var@units = "hPa"
  fileO = fileSafe+"_slp.nc"
  fileS = addfile(fileO, "c")
  fileS->slp = var
  delete(var)
;----------------------------------------------------------------------------
; dX length
;----------------------------------------------------------------------------
  varN  = "RDX"
  varR  = wrf_user_getvar(a,varN,time)
  varR  = 1/varR
  varN  = "MAPFAC_M"
  varF  = wrf_user_getvar(a,varN,time)
  var   = varR/varF
  var@description  = "dX length"
  var@units        = "m"
  fileO = fileSafe+"_dx.nc"
  fileS = addfile(fileO, "c")
  fileS->dx = var
  delete(varR)
  delete(varF)
  delete(var)
;----------------------------------------------------------------------------
; dY length
;----------------------------------------------------------------------------
  varN  = "RDY"
  varR  = wrf_user_getvar(a,varN,time)
  varR  = 1/varR
  varN  = "MAPFAC_M"
  varF  = wrf_user_getvar(a,varN,time)
  var   = varR/varF
  var@description  = "dY length"
  var@units        = "m"
  fileO = fileSafe+"_dy.nc"
  fileS = addfile(fileO, "c")
  fileS->dy = var
  delete(varR)
  delete(varF)
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

; Surface Flux
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
; Geopotential
;----------------------------------------------------------------------------
  varN  = "geopt"
  var   = wrf_user_getvar(a,varN,time)
  var@description  = "Geopotential"
  var@units        = "m2 s-2"
  fileO = fileSafe+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->geopt = var
  delete(var)
;----------------------------------------------------------------------------
; Hydrostatic pressure
;----------------------------------------------------------------------------
  varN  = "P_HYD"
  var   = wrf_user_getvar(a,varN,time)
  var   = var/100
  var@description  = "hydrostatic pressure"
  var@units        = "hPa"
  fileO = fileSafe+"_phyd.nc"
  fileS = addfile(fileO, "c")
  fileS->phyd = var
  delete(var)
;----------------------------------------------------------------------------
; Earth-relative horizontal wind
;----------------------------------------------------------------------------
  ; ua/va are grid-relative.  Every MATLAB diagnostic below subtracts an
  ; east/north track velocity and then forms a geographic cylindrical basis,
  ; so export the already unstaggered, earth-relative pair from WRFUserARW.
  uvmet = wrf_user_getvar(a,"uvmet",time)
  var   = uvmet(0,:,:,:)
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
  var   = uvmet(1,:,:,:)
  var@description  = "Earth-relative northward wind on mass points"
  var@units        = "m s-1"
  var@components    = "northward"
  fileO = fileSafe+"_v.nc"
  fileS = addfile(fileO, "c")
  fileS->v = var
  delete(var)
  delete(uvmet)
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
; Divergence
;----------------------------------------------------------------------------
  varN  = "DIV"
  var   = wrf_user_getvar(a,varN,time)
  var@description  = "Divergence"
  var@units        = "s-1"
  fileO = fileSafe+"_div.nc"
  fileS = addfile(fileO, "c")
  fileS->div = var
  delete(var)
;----------------------------------------------------------------------------
; Earth-relative eastward wind tendency due to PBL parametrization
;----------------------------------------------------------------------------
  ; WRF stores RUBLTEN/RVBLTEN in the same projected x/y basis as U/V.
  ; Rotate the vector with COSALPHA/SINALPHA before it is combined with
  ; earth-relative winds in the storm-following budgets.
  rub = wrf_user_getvar(a,"RUBLTEN",time)
  rvb = wrf_user_getvar(a,"RVBLTEN",time)
  cosalpha = a->COSALPHA(time,:,:)
  sinalpha = a->SINALPHA(time,:,:)
  var   = rub*cosalpha - rvb*sinalpha
  var@description  = "Earth-relative eastward wind tendency due to PBL parametrization"
  var@units        = "m s-2"
  var@components    = "eastward"
  fileO = fileSafe+"_RUBLTEN.nc"
  fileS = addfile(fileO, "c")
  fileS->RUBLTEN = var
  delete(var)
;----------------------------------------------------------------------------
; Earth-relative northward wind tendency due to PBL parametrization
;----------------------------------------------------------------------------
  var   = rub*sinalpha + rvb*cosalpha
  var@description  = "Earth-relative northward wind tendency due to PBL parametrization"
  var@units        = "m s-2"
  var@components    = "northward"
  fileO = fileSafe+"_RVBLTEN.nc"
  fileS = addfile(fileO, "c")
  fileS->RVBLTEN = var
  delete(var)
  delete(rub)
  delete(rvb)
  delete(cosalpha)
  delete(sinalpha)
;----------------------------------------------------------------------------

; Theta Budegt
;----------------------------------------------------------------------------
; Total Advective Theta Tendency
;----------------------------------------------------------------------------
  varN  = "RTHFTEN"
  var   = wrf_user_getvar(a,varN,time)
  var   = var*24*60*60
  var@description  = "TOTAL ADVECTIVE POTENTIAL TEMPERATURE TENDENCY"
  var@units        = "K day-1"
  fileO = fileSafe+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->RTHFTEN = var
  delete(var)
;----------------------------------------------------------------------------
; Theta Tendency due to Radiation
;----------------------------------------------------------------------------
  varN  = "RTHRATEN"
  if (isfilevar(a,varN)) then
    var   = wrf_user_getvar(a,varN,time)
    var   = var*24*60*60
    var@description  = "Theta Tendency due to Radiation"
    var@units        = "K day-1"
    fileO = fileSafe+"_"+varN+".nc"
    fileS = addfile(fileO, "c")
    fileS->RTHRATEN = var
    delete(var)
  end if
;----------------------------------------------------------------------------
; Theta Tendency due to Longwave Radiation
;----------------------------------------------------------------------------
  varN  = "RTHRATLW"
  if (isfilevar(a,varN)) then
    var   = wrf_user_getvar(a,varN,time)
    var   = var*24*60*60
    var@description  = "Theta Tendency due to Longwave Radiation"
    var@units        = "K day-1"
    fileO = fileSafe+"_"+varN+".nc"
    fileS = addfile(fileO, "c")
    fileS->RTHRATLW = var
    delete(var)
  end if
;----------------------------------------------------------------------------
; Theta Tendency due to Shortwave Radiation
;----------------------------------------------------------------------------
  varN  = "RTHRATSW"
  if (isfilevar(a,varN)) then
    var   = wrf_user_getvar(a,varN,time)
    var   = var*24*60*60
    var@description  = "Theta Tendency due to Shortwave Radiation"
    var@units        = "K day-1"
    fileO = fileSafe+"_"+varN+".nc"
    fileS = addfile(fileO, "c")
    fileS->RTHRATSW = var
    delete(var)
  end if
;----------------------------------------------------------------------------
; Diadatic Heating
;----------------------------------------------------------------------------
  varN  = "H_DIABATIC"
  if (isfilevar(a,varN)) then
    var   = wrf_user_getvar(a,varN,time)
    var   = var*24*60*60
    var@description  = "Microphysics Latent Heating"
    var@units        = "K day-1"
    fileO = fileSafe+"_"+varN+".nc"
    fileS = addfile(fileO, "c")
    fileS->H_DIABATIC = var
    delete(var)
  end if
;----------------------------------------------------------------------------
; Theta Tendency due to PBL Parametrization
;----------------------------------------------------------------------------
  varN  = "RTHBLTEN"
  if (isfilevar(a,varN)) then
    var   = wrf_user_getvar(a,varN,time)
    var   = var*24*60*60
    var@description  = "THETA TENDENCY DUE TO PBL PARAMETERIZATION"
    var@units        = "K day-1"
    fileO = fileSafe+"_"+varN+".nc"
    fileS = addfile(fileO, "c")
    fileS->RTHBLTEN = var
    delete(var)
  end if
;----------------------------------------------------------------------------
; Theta Tendency due to Cumulus Parametrization
;----------------------------------------------------------------------------
  varN  = "RTHCUTEN"
  if (isfilevar(a,varN)) then
    var   = wrf_user_getvar(a,varN,time)
    var   = var*24*60*60
    var@description  = "THETA TENDENCY DUE TO CUMULUS PARAMETERIZATION"
    var@units        = "K day-1"
    fileO = fileSafe+"_"+varN+".nc"
    fileS = addfile(fileO, "c")
    fileS->RTHCUTEN = var
    delete(var)
  end if

;----------------------------------------------------------------------------
; Theta Tendency due to Shallow Convection
;----------------------------------------------------------------------------
  varN  = "RTHSHTEN"
  if (isfilevar(a,varN)) then
    var   = wrf_user_getvar(a,varN,time)
    var   = var*24*60*60
    var@description  = "THETA TENDENCY DUE TO SHALLOW CONVECTION"
    var@units        = "K day-1"
    fileO = fileSafe+"_"+varN+".nc"
    fileS = addfile(fileO, "c")
    fileS->RTHSHTEN = var
    delete(var)
  end if

; QV Budget
;----------------------------------------------------------------------------
; Total Advective QV Tendency
;----------------------------------------------------------------------------
  varN  = "RQVFTEN"
  var   = wrf_user_getvar(a,varN,time)
  var   = var*1000
  var@description  = "TOTAL ADVECTIVE MOISTURE TENDENCY"
  var@units        = "g kg-1 s-1"
  fileO = fileSafe+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->RQVFTEN = var
  delete(var)
;----------------------------------------------------------------------------
; Diadatic QV
;----------------------------------------------------------------------------
  varN  = "QV_DIABATIC"
  var   = wrf_user_getvar(a,varN,time)
  var   = var*1000
  var@description  = "MICROPHYSICS QV TENDENCY"
  var@units        = "g kg-1 s-1"
  fileO = fileSafe+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->QV_DIABATIC = var
  delete(var)
;----------------------------------------------------------------------------
; QV Tendency due to PBL Parametrization
;----------------------------------------------------------------------------
  varN  = "RQVBLTEN"
  var   = wrf_user_getvar(a,varN,time)
  var   = var*1000
  var@description  = "QV TENDENCY DUE TO PBL PARAMETERIZATION"
  var@units        = "g kg-1 s-1"
  fileO = fileSafe+"_"+varN+".nc"
  fileS = addfile(fileO, "c")
  fileS->RQVBLTEN = var
  delete(var)
;----------------------------------------------------------------------------

; Diffusive & Viscosity
;----------------------------------------------------------------------------
; Horizontal eddy diffusive
;----------------------------------------------------------------------------
  varN  = "XKHH"
  var   = wrf_user_getvar(a,varN,time)
  var@description  = "Horizontal eddy diffusive"
  var@units        = "m2 s-1"
  fileO = fileSafe+"_kth.nc"
  fileS = addfile(fileO, "c")
  fileS->kth = var
  delete(var)
;----------------------------------------------------------------------------
; Vertical eddy diffusive
;----------------------------------------------------------------------------
  varN  = "XKHV"
  var   = wrf_user_getvar(a,varN,time)
  var@description  = "Vertical eddy diffusive"
  var@units        = "m2 s-1"
  fileO = fileSafe+"_ktv.nc"
  fileS = addfile(fileO, "c")
  fileS->ktv = var
  delete(var)
;----------------------------------------------------------------------------
; Horizontal eddy viscosity 
;----------------------------------------------------------------------------
  varN  = "XKMH"
  var   = wrf_user_getvar(a,varN,time)
  var@description  = "Horizontal eddy viscosity"
  var@units        = "m2 s-1"
  fileO = fileSafe+"_kh.nc"
  fileS = addfile(fileO, "c")
  fileS->kh = var
  delete(var)
;----------------------------------------------------------------------------
; Vertical eddy viscosity
;----------------------------------------------------------------------------
  varN  = "XKMV"
  var   = wrf_user_getvar(a,varN,time)
  var@description  = "Vertical eddy viscosity"
  var@units        = "m2 s-1"
  fileO = fileSafe+"_kv.nc"
  fileS = addfile(fileO, "c")
  fileS->kv = var
  delete(var)
;----------------------------------------------------------------------------

end do
