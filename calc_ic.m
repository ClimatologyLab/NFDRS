function [ic]=calc_ic(temp,fm1,scm,ros,sow);

% this calculates the ignition coefficient (IC)
ic=0;
%  # ALGORITHM TAKEN FROM C CODE
pnorm1 = 0.00232;
pnorm2 = 0.99767;

%  # FROM THE C-CODE (NFDR32.CPP)
tfact = 0.0;
tmpprm = 0.0;
qign = 0.0;
chi = 0.0;
pi = 0.0;
scn = 0.0;
pfi = 0.0;

if sow<=4
    f=find(scm<=0);ic(f)=0;
    switch sow,
        case -1, tfact=0;  % technically this is snow covered, we don't currently have this
        case 0, tfact=25;
        case 1, tfact=19;
        case 2, tfact=12;
        otherwise, tfact=5;
    end
    
    tmpprm = (temp + tfact' - 32) / 1.8;
    qign = 144.5 - (0.266 * tmpprm) - (0.00058 * tmpprm .* tmpprm) - (0.01 * tmpprm .* fm1) + 18.54 * (1 - exp(-0.151 .* fm1)) + 6.4 * fm1;
    if qign>=344
        chi=(344 - qign) / 10;
        pi=((chi(f2).^3.66 * 0.000923 / 50) - pnorm1)* 100 ./ pnorm2;
        if pi >0
            pi=min(pi,100);
            scn(f2)= 100 * ros ./ scm;
            scn=min(scn,100);
            pfi = scn.^0.5;
            ic= ((0.1 * pi .* pfi) + 0.5);
        end
    end
end




