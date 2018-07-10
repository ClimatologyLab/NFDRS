function [fm100,ymc100,fm1000,ym1000,yx1000,prevYear,prevDoy,prevHveg,greendays,colddays,yfherb]= init_carryover_fm(j_date,j_green,climcl,lyear);

%  # MUCH OF THIS FUNCTION IS TAKEN FROM BRADSHAW'S 'INITIAL' CODE

%  # THIS SUBROUTINE IS USED TO GET A STATION STARTED FOR THE YEAR
%  #   IF CARRY OVER VARIABLES ARE UNAVAILABLE FROM THE CATALOG.
%  #   ONCE THERE IS DATA IN THE CATALOG, THIS SHOULD NOT BE CALLED AGAIN

%  # IF NO CATALOG, ASSIGN 100-H FM BASED ON CLIMATE CLASS
fm100 = 5 + 5 * climcl;

%  # ASSIGN YESTERDAYS 100 HRTL FUEL MOISTURE TO THE 100-H FM
ymc100 = fm100;

%  # IF NO CATALOG, ASSIGN 1000-H FM BASED ON CLIMATE CLASS
fm1000 = fm100 + 5;

%  # ASSIGN YESTERDAY'S 1000 HRTL FUEL MOISTURE TO THE 1000-H FM
ym1000 = fm1000;

%  # INIT 7 DAY WEIGHTING ARRAYS
for i=1:7
    bv(:,i)=fm1000;
    tmois(:,i)=fm1000;
end

%  # INITIALZIE FUEL MODEL DEPENDENT CURING RELATED VARIABLES
yx1000 = fm1000;

%  # FROM C-CODE

gg=find(j_date>=j_green(1));
k=setxor(1:length(j_date),gg);
prevYear(gg) = lyear;
prevDoy(gg) = j_date(gg) - 1;
f=find(j_date(gg)>(j_green(1)+7.*climcl(1)));
f1=setxor(1:length(gg),f);
%        prevHveg(gg(f)) = 3;
%        prevHveg(gg(f1)) = 2;
prevHveg(1:length(fm100))=1;
j_green(gg(f1)) = j_date(gg(f1));
%     prevHveg(k) = 1;
prevYear(k) = lyear - 2;
prevDoy(k) = 1;
greendays = zeros(size(fm100));
colddays = zeros(size(fm100));
warmdays = zeros(size(fm100));
gdd = zeros(size(fm100));

yfherb = -99.0*ones(size(fm100));

firsttime = zeros(size(fm100));


prevHveg=prevHveg';

