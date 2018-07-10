function [erc,bi,sc,ros]=calc_indices(w1d,w10d,w100d,w1000d,wherb,wwood,fherbc,depth,sig1d,sig10d,sg100d,s1000d,sgherb,sgwood,fm1,fm10,fm100,fm1000,fmwood,extmoi,hd,ws,wndftr,slopecl,sow,igrass);

   std = 0.0555;                    %# UNKNOWN; WTOTDN, W1n, W10N, W100N
   stl = 0.0555;                    %# UNKNOWN; WTOTLN
   rhod = 32;                       %# FUEL PARTICLE DENSITY; BETBAR
   rhol = 32;                       %# UNKNOWN: SAWOOD
   etasd = 0.4173969;               %# FROM C CODE
   etasl = 0.4173969;               %# FROM C CODE
   slpfct = [0.267 0.533 1.068 2.134 4.273];
   c1 = 0.046;                      %   # MULTIPLIER FOR CONVERTING BETWEEN T/AC AND LBS/SQ FT
   
   slpff=slpfct(slopecl);

%   # MODEL LOADED, CONVERT LOADS FROM T/AC TO LBS/SQ FT
   w1d = w1d .* c1;
   w10d = w10d .* c1;
   w100d = w100d .* c1;
   w1000d = w1000d .* c1;
   wherb = wherb .* c1;
   wwood = wwood .* c1;

%   # FROM XferHerb FUNCTION OF C CODE
   fctcur = 1.33 - 0.0111 .* fherbc;
   fctcur=max(fctcur,0);
   fctcur=min(fctcur,1);

   w1dp = w1d + wherb .* fctcur;
   wherbc = wherb .* (1 - fctcur);

%   # TOTAL LOADING OF LIVE AND DEAD FUEL CATEGORIES
   wtotd = w1dp + w10d + w100d + w1000d;
   wtotl = wwood + wherbc;

%   # WEIGHTING FACTORS FOR ENERGY RELEASE
%   # TOTAL FUEL LOADING
   wtot = wtotd + wtotl;

%   # COMPUTE NET FUEL LOADING
   w1n = w1dp .* (1 - std);
   w10n =w10d .* (1 - std);
   w100n = w100d .* (1 - std);
   whernc = wherbc.* (1 - stl);
   wwoodn = wwood .* (1 - stl);
   wtotln = wtotl .* (1 - stl);

%   # BULK DENSITY ( C++ CODE)
   rhobed = (wtot - w1000d)./ depth;
   rhobar = ((wtotl .* rhol) + (wtotd * rhod))./ wtot;

%   # PACKING RATIO
   betbar = rhobed./ rhobar;

%   # IF THERE ARE LIVE FUELS...(C CODE IS DIFFERENT
   if (wtotln > 0)
%       # HEATING NUMBER FOR EXTLIV
       hnu1 = w1n .* exp(-138 ./ sig1d);
       hnu10 = w10n.* exp(-138 ./ sig10d);
       hnu100 = w100n.* exp(-138 ./ sg100d);
       if -500./sgherb<-180.218 
           hnherb=0; % should this be hbherb??
       else
           hnherb = whernc.* exp(-500 ./ sgherb);
       end
       if -500./sgwood<-180.218
           hnwood=0;
       else
           hnwood=wwoodn.*exp(-500./sgwood);
       end
       

%       # DEAD-LIVE LOADING RATION FOR EXTLIV
    if hnherb+hnwood==0 
        wrat=0;
    else
    wrat = (hnu1 + hnu10 + hnu100) ./ (hnherb + hnwood);
    end
%       # /FINE/ DEAD FUEL MOISTURE CONTENT FOR EXTLIV
    fmff = ((fm1 .* hnu1) + (fm10 .* hnu10) + (fm100 .* hnu100)) ./ (hnu1 + hnu10 + hnu100);

%       # MOISTURE OF EXTINCTION FOR LIVE FUELS (EXTLIV)
    extliv = (2.9 * wrat.* (1 - fmff ./ extmoi) - 0.226) * 100;
    extliv=max(extliv,extmoi);
   else
    extliv=0;
   end



%   #WEIGHTING FACTORS FOR RATE-OF-SPREAD (BY SFC AREA)
   sa1 = (w1dp ./ rhod) .* sig1d;
   sa10 = (w10d ./ rhod) .* sig10d;
   sa100 = (w100d ./ rhod) .* sg100d;
   sherbc = (wherbc ./ rhol) .* sgherb;
   sawood = (wwood ./ rhol) .* sgwood;

%   # TOTAL SFC AREAS OF DEAD AND LIVE FUEL CATEGORIES (BY SFC AREA)
   sadead = sa1 + sa10 + sa100;
   salive = sawood + sherbc;

%   if (sadead <= 0) end

%   # WEIGHTING FACTORS FOR DEAD AND LIVE FUEL CLASSES (BY SFC AREA)
   fct1 = sa1 ./ sadead;
   fct10 = sa10 ./ sadead;
   fct100 = sa100 ./ sadead;

   %   # IF THERE ARE LIVE FUELS PRESENT...
if wtotl>0
       fcherb = sherbc ./ salive;
       fcwood = sawood ./ salive;
else
       fcherb = 0;
       fcwood = 0;
end
   
%   # WEIGHTING FACTORS FOR DEAD AND LIVE FUEL CATEGORIES
   fcded = sadead ./ (sadead + salive);
   fcliv = salive ./ (sadead + salive);

%   # CHARACTERISTIC LOADING OF DEAD AND LIVE FUEL CATEGORIES
   wbar = fct1 .* w1n + fct10 .* w10n + fct100 .* w100n;
   wliv = fcwood .* wwoodn + fcherb .* whernc;

   if sgwood>1200 & sgherb>1200
       wliv=wtotln;
   end
 
%   # WEIGHTED SFC-VOL RATIONS OF DEAD AND LIVE FUEL CATEGORIES
   sgbrd = fct1 .* sig1d + fct10 .* sig10d + fct100 .*sg100d;
   sgbrl = fcwood .* sgwood + fcherb .* sgherb;

%   # CHARACTERISTIC SFC-VOL RATIOS
   sgbrt = sgbrd .* fcded + sgbrl .* fcliv;

%   # OPTIMUM PACKING RATIOS
   betop = 3.348 * (sgbrt.^(-0.8189));

%   # FROM C CODE
   gmamx = (sgbrt.^1.5) ./ (495 + 0.0594 * (sgbrt.^1.5));
   ad = 133 * sgbrt.^(-0.7913);
   gmapm = gmamx .* ((betbar ./ betop).^ad) .* exp(ad .* (1 - (betbar ./ betop)));

%   # PROPOGATING FLUC RATIO (C VERSION)
   zeta = exp((0.792 + 0.681 * (sgbrt.^0.5)) .* (betbar + 0.1));
   zeta = zeta ./ (192 + 0.2595 * sgbrt);

   wtfmd = fct1 .* fm1 + fct10 .* fm10 + fct100 .* fm100;
   wtfml = fcwood .* fmwood + fcherb .* fherbc;

%   # ADDED FROM C VERSION
   dedrt = wtfmd ./ extmoi;
   livrt = wtfml ./ extliv;
   etamd = 1 - 2.59 * dedrt + 5.11 * (dedrt.^2) - 3.52 * (dedrt.^3);
   etaml = 1 - 2.59 * livrt + 5.11 * (livrt.^2) - 3.52 * (livrt.^3);
if etamd < 0 
    etamd = 0;
elseif etamd>1
    etamd=1;
end
if etaml < 0 
    etaml = 0;
elseif etaml>1
    etaml=1;
end


%   # FUEL BED WIND CONTROLLING FACTOR
   c = 7.47 * exp(-0.133 * (sgbrt.^0.55));
   b = 0.02526 * (sgbrt.^0.54);
   e = 0.715 * exp(-3.59 * (10.^(-4)) * sgbrt);
   ufact = c .* ((betbar ./ betop).^(e * (-1)));
   hl=hd;
   ir = gmapm .* ((wbar .* hd .* etamd .* etasd) + (wliv .* hl .* etasl .* etaml));

%   # WIND COEFFICIENT
%   # IF WIND SPEED IS MISSING, ASSIGN IT TO 2MPH FOR NOW
   xws = ws;
   xxws = xws .* wndftr * 88;

%   # LIMIT THE EFFECTIVE WIND SPEED TO 9/10 THE REACTION INTENCITY TO APPROXIMATE THE DROPPING OFF
%   #   OF SPREAD WHEN THE WIND SPEED ACTS AS A HEAT SINK
xxws=min(xxws,.9*ir);
phiwnd = ufact .* (xxws.^b);

%   # SLOPE COEFFICIENT
   phislp = slpff' .* betbar.^(-0.3);

%   # HEAT SINK
   xf1 = fct1 .* exp(-138 ./ sig1d) .* (250 + 11.16 * fm1);
   xf10 = fct10 .* exp(-138 ./ sig10d) .* (250 + 11.16 * fm10);
   xf100 = fct100 .* exp(-138 ./ sg100d) .* (250 + 11.16 * fm100);
   xfherb = fcherb .* exp(-138 ./ sgherb) .* (250 + 11.16 * fherbc);
   xfwood = fcwood .* exp(-138 ./ sgwood) .* (250 + 11.16 * fmwood);
   htsink = rhobed .* (fcded .* (xf1 + xf10 + xf100) +fcliv .* (xfherb + xfwood));

%   # SPREAD COMPONENT
   ros = ir .* zeta .* (1 + phiwnd' + phislp)./ htsink;
   sc = ros+0.5;

%   # WEIGHTING FACTORS FOR DEAD AND LIVE FUEL CLASSES (BY LOAD)
   fct1e = w1dp ./ wtotd;
   fct10e = w10d./ wtotd;
   fc100e = w100d./ wtotd;
   f1000e = w1000d ./ wtotd;

   if (wtotl > 0)
       fwoode = wwood ./ wtotl;
       fhrbce = wherbc ./ wtotl;
   else
       fhrbce = 0;
       fwoode = 0;
   end

%   # WEIGHTING FACTORS FOR DEAD AND LIVE FUEL CATEGORIES (BY LOAD)
   fcdede = wtotd ./ wtot;
   fclive = wtotl ./ wtot;

   wdedne = wtotd .* (1 - std);
   wlivne = wtotl .* (1 - stl);

%   # FOLLOWING ARE BASIC EQUATIONS OF THE RATE OF SPREAD AND ENERGY
%   #   RELEASE MODELS.  THEY ARE TAKEN FROM ROTHERMELS WORK.  VARIABLES
%   #   WITH NAMES ENDING IN /E/ ARE FOR USE IN THE ERC CALC.
   sgbrde = (fct1e .* sig1d) + (fct10e .* sig10d) + (fc100e .* sg100d) + (f1000e .* s1000d);
   sgbrle = (fwoode .* sgwood) + (fhrbce .* sgherb);
   sgbrte = sgbrde .* fcdede + sgbrle .* fclive;

   betope = 3.348 * (sgbrte.^(-0.8189));

%   # FROM C CODE
   gmamxe = (sgbrte.^1.5) ./ (495 + 0.0594 * (sgbrte.^1.5));
   ade = 133 * (sgbrte.^(-0.7913));
   gmapme = gmamxe .* ((betbar ./ betope).^ade) .* exp(ade .* (1 - (betbar./ betope)));

%   # WEIGHTED MOISTURE CONTENT OF DEAD AND LIVE FUEL CATEGORIES
   wtfmde = fct1e .* fm1 + fct10e .* fm10 + fc100e .* fm100 + f1000e .* fm1000;
   wtfmle = fwoode .* fmwood + fhrbce .* fherbc;
   dedrte = wtfmde ./ extmoi;
   livrte = wtfmle ./ extliv;
   etamde = 1 - 2 * dedrte + 1.5 * (dedrte.^2) - 0.5 * (dedrte.^3);
   etamle = 1 - 2 * livrte + 1.5 * (livrte.^2) - 0.5 * (livrte.^3);

   if etamde < 0 
    etamde = 0;
elseif etamde>1
    etamde=1;
   end
if etamle < 0 
    etamle = 0;
elseif etamle>1
    etamle=1;
end
   ire = fcdede .* wdedne .* hd .* etasd .* etamde;
   ire = gmapme.* (ire + (fclive .* wlivne .* hd .* etasl .* etamle));

%   # CALCULATE TAU
   tau = 384 ./ sgbrt;
%ire
%etamde
%etamle
%   # CALCULATE ENERGY RELEASE COMPONENT
   erc = 0.04 * ire.*tau;

%   # CALCULATE BURNING INDEX
   fl = 0.301 * (ros .* erc).^0.46;
   bi = (fl*10)+0.5;

%   # FROM C-CODE (NFDR32.CPP)
if sow>=5 
       ros = 0.0;
       sc = 0;
       bi = 0;
       fl = 0;
end
%   # RESET TO BE SAFE
%    w1d = w1d ./ c1;
%    w10d = w10d ./ c1;
%    w100d = w100d ./ c1;
%    w1000d = w1000d./ c1;
%    wwood = wwood ./ c1;
