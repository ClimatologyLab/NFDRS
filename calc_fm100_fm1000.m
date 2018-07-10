function [fm100,fm1000]=calc_fm100(sow,maxt,mint,pptdur,maxrh,minrh,lat,yrs,climcl);

% initialize starting fm100 and fm1000 based on climate classes

%  # IF NO CATALOG, ASSIGN 100-H FM BASED ON CLIMATE CLASS
fm100 = 5 + 5 * climcl;
fm1000 = fm100 + 5;

% first spin up with generic data
% AVERAGE OF THE BOUNDARY CONDITIONS

%  # INIT 7 DAY WEIGHTING ARRAYS
for i=1:7
    bv(:,i)=fm1000;
    tmois(:,i)=fm1000;
end


% calculate equilibrium moisture contents for day/night
f=find(minrh>50);
f1=find(minrh>10 & minrh<=50);
f2=find(minrh<=10);
f3=find(isnan(minrh)==1);
emc1(f)= 21.0606 + 0.005565 * (minrh(f).^2) - 0.00035 * minrh(f).* maxt(f) - 0.483199 * minrh(f);
emc1(f1) = 2.22749 + 0.160107 * minrh(f1) - 0.014784 * maxt(f1);
emc1(f2) = 0.03229 + 0.281073 * minrh(f2) - 0.000578 * minrh(f2).* maxt(f2);
emc1(f3)=NaN;

clear tmaxt minrh


f=find(maxrh>50);
f1=find(maxrh>10 & maxrh<=50);
f2=find(maxrh<=10);
emc2(f) = 21.0606 + 0.005565 * (maxrh(f).^2) - 0.00035 * maxrh(f).* mint(f) - 0.483199 * maxrh(f);
emc2(f1) = 2.22749 + 0.160107 * maxrh(f1) - 0.014784 * mint(f1);
emc2(f2) = 0.03229 + 0.281073 * maxrh(f2) - 0.000578 * maxrh(f2).* mint(f2);
emc2(f3)=NaN;

f=find(isnan(maxrh)==1);emc1(f)=NaN;emc2(f)=NaN;

clear maxrh mint

for i=1:365
    daylit(i)=calcDaylight(i,lat);
end

emc1=emc1';
emc2=emc2';

daylit=repmat(daylit',[1 yrs]);
daylit=daylit(:);
emc = (daylit.* emc1 + (24.0 - daylit) .* emc2) / 24.0;

clear emc1 emc2 daylit
fr100 = 0.3156;

% run the fm100 calculations, start with initial FM of 10%
ymc=10;
for ndays=1:365*yrs
    bndry1 = ((24 - pptdur(ndays)) .* emc(ndays) + (0.5 * pptdur(ndays) + 41) .* pptdur(ndays)) / 24;
    fm100(ndays) = (bndry1 - ymc)* fr100 + ymc;
    ymc=fm100(ndays);
end

fr1=0.3068;



for ndays=1:365*yrs
    %   # ACCUMULATE A 6-DAY TOTAL
    bv(1:6)=bv(2:7);
    bndry = ((24 - pptdur(ndays)) .* emc(ndays) + (2.7 * pptdur(ndays) + 76).* pptdur(ndays)) / 24;
    bv(7) = bndry;
    
    %   7-day average boundary condition
    bvave = mean(bv);
    
    %   # CALCULATE TODAY'S 1000 HOUR FUEL MOISTURE
    fm1000(ndays) = tmois(1) + (bvave - tmois(1)).* fr1;
    tmois(1:6) = tmois(2:7);
    tmois(7)=fm1000(ndays);
end










