% choose your lat/lon of interest
latr=40.015;
lonr=-108.2705;
% choose fuel model, default =7 (conifer), https://fam.nwcg.gov/fam-web/helpdesk/wims/nfdr.htm
fuelmod=7;

%slope will influence fire behavior metrics, default = 1
% 1 0 ? 25
% 2 26 - 40
% 3 41 - 55
% 4 56 - 75
% 5 greater than 75
slopecl=1;

% Perennial (2) or annual grasses (1), default = 1
igrass=1;

% Climate class determines how fast greenup occurs, https://famit.nwcg.gov/sites/default/files/Appx_F_Detailed_NFDRS_Inputs.pdf
% default = 3
climcl=3;

lat=ncread('http://thredds.northwestknowledge.net:8080/thredds/dodsC/MET/rmax/rmax_2017.nc','lat');
lon=ncread('http://thredds.northwestknowledge.net:8080/thredds/dodsC/MET/rmax/rmax_2017.nc','lon');
flat=find(abs(lat-latr)<1/48);
flon=find(abs(lon-lonr)<1/48);
lat=lat(flat);
lon=lon(flon);
ppt=ncread('http://thredds.northwestknowledge.net:8080/thredds/dodsC/agg_met_pr_1979_CurrentYear_CONUS.nc','precipitation_amount',[flat flon 1],[1 1 Inf],[1 1 1]);
rmax=ncread('http://thredds.northwestknowledge.net:8080/thredds/dodsC/agg_met_rmax_1979_CurrentYear_CONUS.nc','daily_maximum_relative_humidity',[flon flat 1],[1 1 Inf],[1 1 1]);
rmin=ncread('http://thredds.northwestknowledge.net:8080/thredds/dodsC/agg_met_rmin_1979_CurrentYear_CONUS.nc','daily_minimum_relative_humidity',[flon flat 1],[1 1 Inf],[1 1 1]);
tmax=ncread('http://thredds.northwestknowledge.net:8080/thredds/dodsC/agg_met_tmmx_1979_CurrentYear_CONUS.nc','daily_maximum_temperature',[flon flat 1],[1 1 Inf],[1 1 1]);
tmin=ncread('http://thredds.northwestknowledge.net:8080/thredds/dodsC/agg_met_tmmn_1979_CurrentYear_CONUS.nc','daily_minimum_temperature',[flon flat 1],[1 1 Inf],[1 1 1]);
srad=ncread('http://thredds.northwestknowledge.net:8080/thredds/dodsC/agg_met_srad_1979_CurrentYear_CONUS.nc','daily_mean_shortwave_radiation_at_surface',[flon flat 1],[1 1 Inf],[1 1 1]);
vs=ncread('http://thredds.northwestknowledge.net:8080/thredds/dodsC/agg_met_vs_1979_CurrentYear_CONUS.nc','daily_mean_wind_speed',[flon flat 1],[1 1 Inf],[1 1 1]);

ppt=squeeze(ppt);
tmax=squeeze(tmax);
tmin=squeeze(tmin);
rmax=squeeze(rmax);
rmin=squeeze(rmin);

% winds should be in miles per hour at at 20 feet above ground
vs=squeeze(vs)./.45*.85;

srad=squeeze(srad);

% temperature and precipitation should be in Imperial units
tmax=tmax-273.15;
tmin=tmin-273.15;
tmax=tmax*1.8+32;
tmin=tmin*1.8+32;
ppt=ppt/25.4;

% for ease of use, convert data into matrix - day x year


time=ncread('http://thredds.northwestknowledge.net:8080/thredds/dodsC/agg_met_pr_1979_CurrentYear_CONUS.nc','day');
dayofyear=datevec(double(time)+datenum(1900,1,1));
f=find(dayofyear(:,1)<=2017);
tmax=tmax(f);tmin=tmin(f);rmax=rmax(f);rmin=rmin(f);ppt=ppt(f);vs=vs(f);srad=srad(f);dayofyear=dayofyear(f,:);

dayofyear=datenum(dayofyear)-datenum([dayofyear(:,1) ones(size(dayofyear,1),1) zeros(size(dayofyear,1),1)]);

% truncate 366-day years
f=find(dayofyear<=365);
tmax=tmax(f);tmin=tmin(f);rmax=rmax(f);rmin=rmin(f);ppt=ppt(f);vs=vs(f);srad=srad(f);dayofyear=dayofyear(f,:);
tmax=reshape(tmax,365,39);
tmin=reshape(tmin,365,39);
rmin=reshape(rmin,365,39);
rmax=reshape(rmax,365,39);
ppt=reshape(ppt,365,39);
vs=reshape(vs,365,39);
srad=reshape(srad,365,39);

maxsolar=potential_solar(lat,[1:365]);

% method 1 uses just hourly precipitation
%   - ppt should be precipitation for the hour prior to 1300
%  method 2 calulates SOW using subfunction calcSOW using precipitation and solar radiation
%    - rad is downward shortwave radiation, preferably at 1300, but daily
%    mean also works; potrad is the potential clear sky solar radiation'
%    - ppt is a daily total% sowmethod is the method for calculation

% convert precipitation amount to duration

[sow]=calcsow(srad,ppt,maxsolar');
pptdur=pduration(ppt,lat,lon);
pptdur=pptdur(:);
sow=sow(:);

% if you don't have 1300 temp and rh, I just cut a couple degrees of the
% max temp, and humidity
temp=tmax-2;rh=rmin+2;
yr=repmat([1979:2017],[1 365])';
[fm1,fm10,fm100,fm1000,erc,bi,sc,ic,ros]=NFDRS_run(temp,tmax,tmin,rh,rmax,rmin,pptdur,sow,vs,lat,dayofyear,yr,fuelmod,slopecl,igrass,climcl);
plot(reshape(erc,365,39),'k');hold on;plot(mean(reshape(erc,365,39),2),'r','linewidth',3);