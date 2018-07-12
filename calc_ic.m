function [ic]=calc_ic(temp,fm1,scm,sc,sow);

% this calculates the ignition coefficient (IC)
ic=0;

if sow<=4 & scm>0
    switch sow,
        case -1, tfact=0;  % technically this is snow covered, we don't currently have this
        case 0, tfact=25;
        case 1, tfact=19;
        case 2, tfact=12;
        otherwise, tfact=5;
    end
    
    %  # ALGORITHM TAKEN FROM C CODE
pnorm1 = 0.00232;
pnorm2 = 0.99767;
pnorm3 =  0.0000185;


    tmpprm = (temp + tfact);
    qign = 144.5 - (0.266 * tmpprm) - (0.00058 * tmpprm^2) - (0.01 * tmpprm .* fm1) + 18.54 * (1 - exp(-0.151 .* fm1)) + 6.4 * fm1;
    qign=min(344,qign);
    chi=(344-qign)/10;
        pi=((chi.^3.66 * pnorm3) - pnorm1)* 100 ./ pnorm2;
        if pi>0
            pi=min(pi,100);
            scn= 100 * sc ./ scm;
            scn=min(scn,100);
            pfi = scn.^0.5;
            ic= ((0.1 * pi .* pfi));
        end
    end
end




