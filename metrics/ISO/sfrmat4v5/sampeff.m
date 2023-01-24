function [eff, freqval, sfrval] = sampeff(dat, val, del, fflag, pflag)
%sampeff(datout{ii}, [0.1, 0.5],  del, 1, 0);
%[eff, freqval, sfrval] = sampeff2(dat, val, del, fflag, pflag) Sampling efficiency from SFR
% First clossing method with local interpolation
%dat   = SFR data n x 2, n x 4 or n x 5 array. First col. is frequency
%val = (1 x n) vector of SFR threshold values, e.g. [0.1, 0.5]
%del = sampling interval in mm (default = 1 pixel)
%fflag = 1 filter [1 1 1 ] filtr applied to sfr
%      = 0 (default) no filtering
%pflag = 0 (default) plot results
%      = 1 no plots
%
%Peter Burns 6 Dec. 2005, modified 19 April 2009
%
if nargin < 4;
    pflag = 0;
    fflag =0;
end
if nargin < 3;
    del = 1;
end
if nargin < 2;
    val = 0.1;
end


%hs = 0.48/del;  changed 19 April 2009
hs = 0.495/del;
imax= length(dat(:,1)); % added 19 April 2009
x = find(dat(:,1) > hs);
if isempty(x) == 1;
    disp(' Missing SFR data, frequency up to half-sampling needed')
    eff = 0;  %%%%%
    freqval = 0;
    sfrval = 0;
    return
end
nindex = x(1);  % added 19 April 2009
%imax = x(1);   % Changed 19 April 2009
dat = dat(1: imax, :);

[n, m, nc] = size(dat);
nc = m - 1;
imax = n;
nval = length(val);
eff = zeros(nval, nc);
freqval = zeros(nval, nc);
sfrval = zeros(nval, nc);

for v = 1: nval;
 [freqval(v, :), sfrval(v, :)] = findfreq(dat, val(v), imax, fflag);
 freqval(v, :)=clip(freqval(v, :),0, hs); %added 19 April 2009 ****************
for c = 1:nc
  %eff(v, c) = min(round(100*freqval(v, c)/dat(imax,1)), 100);
  eff(v, c) = min(round(100*freqval(v, c)/hs), 100); %  ************************
end
end

if pflag ~= 0;
    
for c =1:nc
 se = ['Sampling efficiency ',num2str(eff(1,c)),'%'];
  
 disp(['  ',se])
 figure,
	plot(dat(:,1),dat(:,c+1)),
	hold on
    for v = 1:nval
     plot(freqval(v, c),sfrval(v, c),'r*','Markersize', 12),
    end
     plot(dat(:,1),0.1*ones(length(dat(:,1))),'b--'),
     plot([dat(nindex,1),dat(nindex,1)],[0,.1],'b--'),
%     title(fn),
     xlabel('Frequency'),
     ylabel('SFR'),
     text(0.8*dat(end,1),0.95, ['SE = ',num2str(eff(1,c)),'%'])
     axis([0, dat(imax, 1), 0, 1]),
     hold off
end

end     