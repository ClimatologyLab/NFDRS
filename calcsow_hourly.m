function [SOW]=calcsow_hourly(RAD,PPT,maxrad);
% PPT is precipitation that fell within the last hour ending 1300
% RAD and maxrad are solar radiation at 1300
% max radiation is clear sky radiation
SOW=zeros(size(PPT);
pofclouds=RAD./repmat(maxrad,[1 size(RAD,2)]);
f=find(PPT<0.01 & pofclouds>=0.91);SOW(f)=0;
f=find(PPT<0.01 & pofclouds<0.91 & pofclouds>=0.73);SOW(f)=1;
f=find(PPT<0.01 & pofclouds<0.73 & pofclouds>0.5);SOW(f)=2;
f=find(PPT<0.01 & pofclouds<=0.5);SOW(f)=3;
f=find(PPT>=0.01);SOW(f)=6;
