function [w1d,w10d,w100d,w1000d,wwood,wherb,sig1d,sig10d,sg100d,s1000d,sgwood,sgherb,hd,scm,extmoi,depth,wndftr]=get_fuel_param(fueltype);
  [h,data]=hdrload('fuelmdata.txt');
data=double(data/1.0);
  w1d=data(fueltype,1);
  w10d=data(fueltype,2);
  w100d=data(fueltype,3);
  w1000d=data(fueltype,4);
  wwood=data(fueltype,5);
  wherb=data(fueltype,6);
  sig1d=data(fueltype,7);
  sig10d=data(fueltype,8);
  sg100d=data(fueltype,9);
  s1000d=data(fueltype,10);
  sgwood=data(fueltype,11);
  sgherb=data(fueltype,12);
  hd=data(fueltype,13);
  scm=data(fueltype,14);
  extmoi=data(fueltype,15);
  depth=data(fueltype,16);
  wndftr=data(fueltype,17);


f=find(sig1d<=0);sig1d(f)=2000;
f=find(sig10d<=0);sig10d(f)=109;
f=find(sg100d<=0);sg100d(f)=30;
f=find(s1000d<=0);s1000d(f)=8;
f=find(sgwood<=0);sgwood(f)=1;
f=find(sgherb<=0);sgherb(f)=1;

