function [maxsolar]=potential_solar(lat,day,Z);
% inputs, latitude, day of year, and elevation
% Z is elevation, optional in meters

if nargin==2 Z=0;end
% assumed to be 75% TOA shortwave radiation or cloudless day, FAO, 1998
% taken from ASCE penman montieth code

GSC = 0.082; % MJ m -2 min-1 (solar constant)

phi = pi*lat/180;


    dr = 1+0.033*cos(2*pi/365 * day);
    delta = 0.409 * sin(2*pi/365*day-1.39);
    omegas = acos(-tan(phi).*tan(delta));
    Ra = 24*60*GSC/pi.*dr .* ( omegas .*sin(phi).*sin(delta) +cos(phi).*cos(delta).*sin(omegas) ); % FAO daily
    maxsolar = Ra .* (0.75+2e-5*Z);


maxsolar=maxsolar/.0864;

% output in W/m2