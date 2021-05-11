function q = jpeg_qtables(qfactor, qtable)
% q = jpeg_qtables(qfactor, qtable)
%
% Scales the qtable according to IJG's code.
% qfactor should be between 1 and 100. If not, the value is
% clamped to be in the [1, 100] range.
%
% If qtable is a scalar, return the JPEG default tables.
% qtable=1, return standard luminance table;
% qtable=2, return standard chrominance table.
%
% Xuemei Zhang 11/12/96
% Last modified 2/13/97

if (qfactor < 1)
    qfactor = 1;
end
if (qfactor > 100)
    qfactor = 100;
end

if (qfactor < 50)
    qfactor = 5000 / qfactor;
else
    qfactor = 200 - qfactor * 2;
end

%% if qtable is a scalar, use it as standard table number

%% qtable=1, return standard luminance table;

%% qtable=2, return standard chrominance table.
if (length(qtable) == 1)
    if (qtable == 1)
        qtable = [16, 11, 12, 14, 12, 10, 16, 14; ...
            13, 14, 18, 17, 16, 19, 24, 40; ...
            26, 24, 22, 22, 24, 49, 35, 37; ...
            29, 40, 58, 51, 61, 60, 57, 51; ...
            56, 55, 64, 72, 92, 78, 64, 68; ...
            87, 69, 55, 56, 80, 109, 81, 87; ...
            95, 98, 103, 104, 103, 62, 77, 113; ...
            121, 112, 100, 120, 92, 101, 103, 99];
    end
    if (qtable == 2)
        qtable = [17, 18, 18, 24, 21, 24, 47, 26; ...
            26, 47, 99, 66, 56, 66, 99, 99; ...
            99, 99, 99, 99, 99, 99, 99, 99; ...
            99, 99, 99, 99, 99, 99, 99, 99; ...
            99, 99, 99, 99, 99, 99, 99, 99; ...
            99, 99, 99, 99, 99, 99, 99, 99; ...
            99, 99, 99, 99, 99, 99, 99, 99; ...
            99, 99, 99, 99, 99, 99, 99, 99];
    end
end

q = floor((qtable*qfactor+50)/100);
q = truncate(q, 1, 255);
