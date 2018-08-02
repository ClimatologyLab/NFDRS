function [gsi]=calculateGSI(vpd,tmmn,lat,el);

% per Jolly, 2005
% calculate VPD component
f=find(vpd<=.9);f1=find(vpd>.9 & vpd<4.1);f2=find(vpd>=4.1);

vpd(f2)=0;
vpd(f)=1;
vpd(f1)=1-(vpd(f1)-.9)/3.2;
clear sph

% calculate daylight from latitude and day of year

for i=1:size(tmmn,1)
 [daylit(i)]=calcDaylight(i,lat);
end
f=find(daylit>10 & daylit<11);dayl(f)=(daylit(f)-10)/11;
f=find(daylit<=10);dayl(f)=0;f=find(daylit>=11);dayl(f)=1;

% calculate tmmn component
f1=find(tmmn>-2 & tmmn<5);
f2=find(tmmn<=-2);
f=find(tmmn>=5);
tmmn(f)=1;
tmmn(f2)=0;
tmmn(f1)=(tmmn(f1)+2)/7;
dayl=repmat(dayl',[1 size(vpd,2)]);

%plot(tmmn(:,1));hold on;plot(vpd(:,1));plot(dayl(:,1))
gsi=tmmn.*vpd.*dayl;

gsi=movmean(gsi(:),[20 0]);
gsi=reshape(gsi,size(vpd));

function [vpd]=calcVPD(tmax,tmin,sph,Z);
% SATVAP: computes saturation vapor pressure
% q=satvap(Ta) computes the vapor pressure at satuation at air
% temperature Ta (deg C). From Gill (1982), Atmos-Ocean Dynamics, 606.
%
%    INPUT:   Ta- air temperature  [C]
%             p - pressure (optional)  [mb]
%
%    OUTPUT:  q  - saturation vapour pressure  [mb]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3/8/97: version 1.0
% 8/27/98: version 1.1 (corrected by RP)
% 8/5/99: version 2.0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% send data in degrees C

P=1013.25*(1-.0001*Z);

sph=sph/.622;%
sph=sph.*P;
e1=log(sph/6.112);
Td=243.5*e1./(17.67-e1);






% solve for vapor pressure at maximum temp
ew=power(10,((0.7859+0.03477*tmin)./(1+0.00412*tmin)));
fw=1 + 1e-6*P.*(4.5+0.0006*tmin.^2);
ew_tmin=fw.*ew;

ew=power(10,((0.7859+0.03477*tmax)./(1+0.00412*tmax)));
fw=1 + 1e-6*P.*(4.5+0.0006*tmax.^2);
ew_tmax=fw.*ew;

% solve for vapor pressure at dewtemp
ew=power(10,((0.7859+0.03477*Td)./(1+0.00412*Td)));
fw=1 + 1e-6*P.*(4.5+0.0006*Td.^2);
ew_tdew=fw.*ew;

vpd=(ew_tmax/2+ew_tmin/2)-ew_tdew;

