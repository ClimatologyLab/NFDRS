function [fm10,fm1]=calc_fm10(temp,rh,sow);
% code computes daily 1-hr and 10-hr dead fuel moistures (fm1, fm10)
% inputs: temp, rh; these should be instantaneous, typically 1300




%   # THIS SUBROUTINE CALCULATES FM10.  THERE IS ADDITIONAL CODE
%   #   IN BRADSHAW FOR WHEN THE CURRENT FM10 IS LE 0.  THIS HAS NOT BEEN
%   #   INTEGRATED IN THIS CODE AS OF YET.  ALSO, SOW HAS YET TO BE DETERMINED,
%   #    SO THAT WILL HAVE TO BE ADJUSTED FOR LATER.
%   # THIS SUBROUTINE ALSO USES THE ORIGINAL EMC CALCULATION INSTEAD OF THE
%   #   ONE WHICH USES HF AND TF.  THIS CAN BE EMPOLYED LATER ONCE SOW IS KNOWN
%
%   # ACCORDING TO BRADSHAW [EMAIL] THIS PROGRAM WILL ALWAYS START WITH FM10=0
%   # SINCE THE SOW IS 0, FM10/FM1 SHOULD ONLY BE CALCULATED BASED UPON EMD
%   #    AND FM100
%
%   # LARRY'S CODE COMPUTES A SINGLE EMC BASED UPON THE TEMP/RH ADJUSTMENTS
%   #    CORRESPONDING TO SOW=0 (I.E. 1ST ELEMENT IN ADJUSTMENT ARRAYS) <VIA
%   #    EMAIL WITH LARRY 12/07/01>
%
%   # NEW ACCOUTING FOR SOW (CHRIS FONTANA (3/12/02): ASSUME SOW IS 0
%   #   DURING THE DAY AND 3 AT NIGHT.  IF PRECIP IS RECEIVED IN
%   #   PREVIOUS HOUR, THE SOW WILL BE 8.  IF PRECIP IS RECEIVED IN
%   #   PREVIOUS 2 HOURS, THE SOW WILL BE 6

   tfct = [25,19,12,5];
   hfct = [0.75,0.83,0.92,1.00];
sw1=sow;
f3=find(sow>=3);
sw1(f3)=3;

f1=find(sw1==0);
temp(f1)=temp(f1)+25;rh(f1)=rh(f1)*.75;
f1=find(sw1==1);
temp(f1)=temp(f1)+19;rh(f1)=rh(f1)*.83;
f1=find(sw1==2);
temp(f1)=temp(f1)+12;rh(f1)=rh(f1)*.92;
f1=find(sw1==3);
temp(f1)=temp(f1)+5;

f1=find(rh>50);
f2=find(rh<=50 & rh>10);
f3=find(rh<=10);

         emcf10(f1) = 21.0606 + 0.005565.* (rh(f1).^2.0) - 0.00035 *rh(f1).*temp(f1) - 0.483199 * rh(f1);
        emcf10(f2) = 2.22749 + 0.160107 * rh(f2) - 0.014784 * temp(f2);
        emcf10(f3) = 0.03229 + 0.281073 * rh(f3) - 0.000578 * rh(f3).* temp(f3);

f=find(isnan(temp)==1);
emcf10(f)=NaN;
fm10(f)=NaN;


f=find(sow>4);
% whenever there is recent precipitation, FM10 and FM1 get set to 35%

      fm10 = 1.28 * emcf10;
      fm10(f) = 35.;     
      fm1=1.03*emcf10;
      fm1(f)=35;



      

