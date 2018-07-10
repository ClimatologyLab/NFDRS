function [j_green, warmdays, colddays, hveg,gdd]=calc_vegstage(maxt,mint,warmdays,colddays,j_date,j_green, gdd,hveg);

% this is a phenology tracker that uses GDD to determine greenup
% # RESET TO '1' AT BEG OF YEAR
if (j_date == 1) hveg = 1;end
if maxt > 32
    warmdays=warmdays+1;
else
    warmdays = 0;
end

if hveg == 1 %    # CURRENTLY IS PRE-GREEN
    %      # DETERMINE GROWING DEGREE DAYS (GDD)
    %      #     SUM DAILY MAXT AND MINT, DIVIDE BY 2, SUBTRACT 32
    %      #     WHEN GDD REACHES 300, GREENUP BEGINS
    %      #     CALCULATION STARTS AFTER 5 CONSECUTIVE DAYS OF TEMP > 32F
    %      # GREEN-UP CAN ONLY OCCUR BETWEEN MAR 1 AND JUL 15
    if (j_date >= 60 && j_date <= 212)
        if (warmdays > 5)
            
            gdd =gdd+ (maxt + mint) / 2 - 32;
            if (gdd > 300)
                hveg = 2;
                %                  # DO GREEN-UP DATE
                j_green = j_date;
                colddays = 0;  % RE-INITIALIZE COLDDAYS
            end
        else
            gdd = 0;
        end
    end
end
if hveg == 5%  # CURRENTLY IN CURRING
    if (mint < 32)
        colddays=colddays+1;
    end
    if (colddays >= 3)
        hveg = 6;
    end
end


end
