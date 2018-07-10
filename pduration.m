function [pdur]=pduration(ppt,lat,lon);
% ppt in inches

% look up table from Matt Jolly that converts # to duration [no seasonal
% adjustment makes this real weird]

m=matfile('../../../pduration_jolly2.mat');
mlat=m.y(:,1);mlon=m.x(1,:);
flat=find(abs(mlat-lat)<1/24);flat=flat(1);
flon=find(abs(mlon-lon)<1/24);flon=flon(1);
Z3=m.Z3(flat,flon);
pdur=pduration_jolly(ppt,Z3);
pdur=round(pdur);
% NFDRS says it never rains more than 8 hours in a day, ha!!
f=find(pdur>8);pdur(f)=8;
clear ppt srad



function [pdur]=pduration_jolly(ppt,b);
pdur=NaN*ones(size(ppt));
f=find(ppt==0);
pdur(f)=0;
f=find(ppt>0);
pdur(f)=24*(1-exp(-b.*ppt(f)));