function [freqval, sfrval] = findfreq(dat, val , imax, fflag)
%[freqval, sfrval] = findfreq(dat, val, imax, fflag) find frequency for specified
%SFR value
% dat   = SFR data n x 2, n x 4 or n x 5 array. First col. is frequency
% val = threshold SFR value, e.g. 0.1
% imax = index of half-sampling frequency (normally n)
%fflag = 1  filter [1 1 1] SFR data
%      = 0 no filter (default)
% freqval = frequency corresponding to val; (1 x ncolor)
% SFR corresponding to val (normally = val) (1 x ncolor)
%
%Peter Burns 6 Dec. 2005

if nargin < 4;
    fflag = 0;
end

[n, m, nc] = size(dat);
nc = m - 1;
frequval = zeros(1, nc);
sfrval = zeros(1, nc);

maxf = dat(imax,1);
fil = [1, 1, 1]/3;
fil = fil';
for c = 1:nc;
    if fflag ~= 0;
        temp = conv2(dat(:, c+1), fil, 'same');
	    dat(2:end-1, c+1) = temp(2:end-1);
    end
    test = dat(:, c+1) - val;
	x = find(test < 0) - 1; % First crossing of threshold
   
	if isempty(x) == 1 | x(1) == 0;
        
		s = maxf;
        sval = dat(imax, c+1);

		else                 % interpolation
        x = x(1);
        sval = dat(x, c+1);
        s = dat(x,1);
		y = dat(x, c+1);
        y2 = dat(x+1, c+1);
        slope = (y2-y)/dat(2,1);
        dely =  test(x, 1);
        s = s - dely/slope;
        sval = sval - dely; 
    end
    if s > maxf;
       s = maxf;
       sval = dat(imax, c+1);
    end
    
    freqval(c) = s;
    sfrval(c) = sval;
    
end