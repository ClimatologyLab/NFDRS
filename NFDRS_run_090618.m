function [fm1,fm10,fm100,fm1000,erc,bi,sc,ic,ros]=firedanger1(temp,tmax,tmin,rh,rmax,rmin,pptdur,sow,ws,greenup,lat,doy,yr,fuelmod,slopecl,igrass,climcl);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  This program and its
%       algorithms are based heavily off of L. Bradshaw's nfdrcalc.for
%       function.
%
%  BLH:08/24/00:started
%  BLH:11/06/00:after diagraming LB's entire program of all parameters; now modify
%       program for more structure
%  BLH:03/08/01:integrate LB comments to try and solidify code so that it works!
%  BLH:03/13/01:modify to read in master RAWS list
%  BLH:10/02/01:only write to catalogue once a day
%  BLH:5/7/02:removed all code in the 'curing' section that redefined the
%       veg stage.  Will always make the catalogues determine the stage
%  BLH:9/24/02: modify this particular code to read in WIMS data format
%  JTA: 3/4/08: modified to MATLAB
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% could add GSI code in to initiate greenup rather than temperature  based
% approach currently used.

nyr=length(unique(yr));
years=unique(yr);

% first calculate the 1-10-100-and 1000 hour fuel moistures

[fm100,fm1000]=calc_fm100_fm1000(sow,tmax,tmin,pptdur,rmax,rmin,lat,nyr,climcl);
[fm10,fm1]=calc_fm10_fm1(temp,rh,sow);

clear rh* pptdur tptot

ordir=pwd;

cd (ordir)

% get coefficients based on selected fuel model
[w1d,w10d,w100d,w1000d,wwood,wherb,sig1d,sig10d,sg100d,s1000d,sgwood,sgherb,hd,scm,extmoi,depth,wndftr]=get_fuel_param(fuelmod);

j_date=doy(1);
lyear=yr(1);
%gr_date = gsi(1);
%j_green=gr_date;
hveg=1;
greendays = 0;
yfherb = 50;
yfwood= 50;
ym1000=fm1000(1);
yx1000=fm1000(1);
j_green=0;
% this identifies the Jan 1st for keeping track
gg=find(doy==1);gg=gg-1;gg(length(gg)+1)=length(doy);

% loop over years
for jyr=1:nyr
j_green = greenup(jyr);
%gr_date=j_green;
yearnum=years(jyr);
%ndd=max(doy(find(yr==yearnum)));

%loop over days
for ij=1:365 
  
ii=gg(jyr)+ij;
j_date=doy(ii);
lyear=yr(ii);

% CALCULATE CURING FROM CURING FUNCTION (78)
[fmwood,fherbc,x1000,hveg,greendays]=calc_curing(climcl,j_date,j_green,fm1(ii),ym1000,hveg,fm1000(ii),tmax(ii),tmin(ii),yx1000,igrass,yfherb,greendays,yfwood);

% CALCULATE INDICES AND STORE IN HASH PER STATION (ALL C VERSION)
[erc(ii),bi(ii),sc(ii),ros(ii)]=calc_indices(w1d,w10d,w100d,w1000d,wherb,wwood,fherbc,depth,sig1d,sig10d,sg100d,s1000d,sgherb,sgwood,fm1(ii),fm10(ii),fm100(ii),fm1000(ii),fmwood,extmoi,hd,ws(ii),wndftr,slopecl,sow(ii),igrass);


% CALCULATE IGNITION COMPONENT
[ic(ii)]=calc_ic(temp(ii),fm1(ii),scm,sc(ii),sow(ii));
 woodm(ii)=fmwood;
 herbm(ii)=fherbc;
 ym1000=fm1000(ii);
 yx1000=x1000;
 yfherb=fherbc;
 yfwood=fmwood;
 vegs(ii)=hveg;
end
end
end


