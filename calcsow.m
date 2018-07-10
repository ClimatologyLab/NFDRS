function [SOW]=calcsow_daily(RAD,PPT,maxrad);
% PPT is hourly ppt amount in inches/hr, often considered as 24 sum/24 hours
% max radiation is clear sky radiation
SOW=zeros(size(PPT));
f=find(PPT>=0.05); 
SOW(f)=6;
f=find(PPT>=0.01 & PPT<0.05);
SOW(f)=5;
pofclouds=RAD./repmat(maxrad,[1 size(RAD,2)]);
f=find(PPT<0.01 & pofclouds>=0.91);SOW(f)=0;
f=find(PPT<0.01 & pofclouds<0.91 & pofclouds>=0.73);SOW(f)=1;
f=find(PPT<0.01 & pofclouds<0.73 & pofclouds>0.5);SOW(f)=2;
f=find(PPT<0.01 & pofclouds<=0.5);SOW(f)=3;