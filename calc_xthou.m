function [xthou]=calc_xthou(fm1000,ym1000,maxt,mint,yx1000);

%   #XTHOU = F(YX1000,DAMPNO,DIFF)
   diff = 0;
   dampno = 0;

   diff1 = fm1000 - ym1000;

%   # THIS IF CLAUSE IF FROM THE FF+ CODE

if fm1000>25 %& diff1<=0
    
    dampno=1;
else
    dampno= 0.167+0.033*fm1000;
end

   tavg = (maxt + mint) / 2;
if tavg<=50
    dampno = 0.6 * dampno;
end
   xthou = yx1000 + dampno.* diff1;

