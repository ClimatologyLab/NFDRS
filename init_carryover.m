function [prevHveg,greendays,colddays,yfherb]= init_carryover_fm(j_date,j_green,climcl,lyear);

%  # MUCH OF THIS FUNCTION IS TAKEN FROM BRADSHAW'S 'INITIAL' CODE

%  # THIS SUBROUTINE IS USED TO GET A STATION STARTED FOR THE YEAR
%  #   IF CARRY OVER VARIABLES ARE UNAVAILABLE FROM THE CATALOG.
%  #   ONCE THERE IS DATA IN THE CATALOG, THIS SHOULD NOT BE CALLED AGAIN

%  # IF NO CATALOG, ASSIGN 100-H FM BASED ON CLIMATE CLAS
%  # FROM C-CODE

prevHveg=1;
prevDoy = 1;
greendays = 0;
colddays = 0;
warmdays = 0;
gdd = 0;
yfherb = -99;


