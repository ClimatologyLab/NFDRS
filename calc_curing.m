function [fmwood,fherbc,x1000,colddays,hveg,greendays] =calc_curing(climcl,j_date,j_green,fm1,ym1000,colddays,hveg,fm1000,maxt,mint,yx1000,igrass,yfherb,greendays,yfwood);

%   # DECLARE CONSTANTS
%       # BOTH ANNUAL AND PERENNIALS WHEN GREEN (FHERBC ABOVE 120%)
herbga = [-70.0,-100.0,-137.5,-185.0];
herbgb = [12.8,14.0,15.5,17.4];

%       #ANNUALS DURING TRANSITION (FHERBC 30-120%)
hcurta = [-150.5,-187.7,-245.2,-305.2];
hcurtb = [18.4,19.6,22.0,24.3];

%       #PERENNIALS DURING TRANSITION
hlivta = [11.2,-10.3,-42.7,-93.5];
hlivtb = [7.4,8.3,9.8,12.2];

%       #SHRUBS OVER THE ENTIRE RANGE OF FMWOOD
wooda = [12.5,-5.0,-22.5,-45.0];
woodb = [7.5,8.2,8.9,9.8];

%       # PRE-SEASON AND POST-FREEZE VALUES FOR FMWOOD
pregrn = [50.0,60.0,70.0,80.0];

fherbf = zeros(size(fm1));

woodaa=wooda(climcl);
woodbb=woodb(climcl);
fmwodi=pregrn(climcl);

if yfwood>pregrn(climcl) fmwodi=yfwood;end

fmwodf = woodaa + woodbb.* fm1000;
if hveg==1 | hveg==6
    fmwood = fmwodi;
else
    fmwood = min(200, fmwodf);
end




%   #$yfherb = $fherbc;  # TO MATCH C-CODE  #REMOVED SINCE FHERBC WASN'T INITIALIZED
%fherbc=0;
if hveg<1 | hveg>6 hveg=1;end

switch hveg
    case 1,  % dormant
        fherbc=fm1;x1000=fm1000;
        if j_date>=j_green
            greendays=0;hveg=2;
        end
    case 2,  % greenup stage
        x1000=calc_xthou(fm1000,ym1000,maxt,mint,yx1000);
        greendays=greendays+1;
        gren = 100 * greendays ./ (7 * climcl);
        fherbf = herbga(climcl) + herbgb(climcl).*x1000;
        fherbf=min(fherbf,250);
        fherbc = fm1+ gren.* (fherbf - fm1) / 100;
        fherbc=min(fherbc,250);
        if gren>=100 & fherbc>=120 hveg=3;end
        if gren>=100 & fherbc<120 hveg=4;end
        if (j_date<=j_green+7*climcl)
            fmwood =fmwodi + gren'.* (fmwodf - fmwodi)/ 100;
        end
    case 3,  % green stage
        x1000=calc_xthou(fm1000,ym1000,maxt,mint,yx1000);
        fherbc = herbga(climcl) + herbgb(climcl).* x1000;
        if yfherb <0 yfherb=fherbc;end
        if igrass ~= 1
            fherbc=min(fherbc,yfherb);
        end
        fherbc=min(fherbc,250);
        if fherbc<=120 hveg=4;end
    case 4,  % transition stage
        x1000=calc_xthou(fm1000,ym1000,maxt,mint,yx1000);
        if igrass~=2
            fherbc = hlivta(climcl)+hlivtb(climcl).*x1000;
        else
            fherbc = hcurta(climcl) + hcurtb(climcl).* x1000;
        end
        if yfherb < 0 yfherb = fherbc;end;
        if igrass~=1
            fherbc = min(fherbc, yfherb);
        end
        if fherbc < 30 fherbc = 30;hveg=5;end
        fherbc=min(fherbc,150);
    case 5, % cured
        x1000 = fm1000;
        if igrass~=2
            fherbc = hlivta(climcl)+hlivtb(climcl).*x1000;
            fherbc=max(fherbc,30);
            fherbc=min(fherbc,150);
        else
            fherbc = fm1;
        end
    case 6,  % frozen
        colddays = 0;
        x1000 = fm1000;
        fherbc = fm1;
end
fmwood=max(fmwood,pregrn(climcl));
