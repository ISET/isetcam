function fList = unitFrequencyList(N)
% Calculate a vector of normalized frequencies for an N-vector
%
%   fList = unitFrequencyList(N)
%
% The list is calculated given an input that that is N-samples long. This
% routine handles the case when N is even and odd.
%
% The range that comes back, say when N = 100 or N = 101, the DC term is at
% location 51.  The general rule is that if N is even the DC location is at
% N/2 +1. If N is odd, the DC location is at (N+1)/2.
%
% The main purpose is to get the zero (DC) term into the proper position
% where Matlab expects it.  Then, once we know the maximum frequency
% (Nyquist) in our measurement, we can multiply the returned list here
% times that maximum frequency.
%
% N.B. This routine had a bug for a long time.  Sorry. The DC location was
% improperly placed. Fixed 2005.12.27, I hope.
%
% Examples:
%   fList = unitFrequencyList(50);
%   fList = unitFrequencyList(51);
%   dataFrequencies = fList*nyquistFrequency;
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('N'), N = 6; end

% Figure out which entry represents DC
if isodd(N), mid = (N+1)/2; else mid = N/2 + 1; end

% Here is a list of frequencies
c = 1:N;

% Subtract so that the one at the mid position is zero
c = c - c(mid);

% Normalize so that the largest value is +/-1
fList = c/max(abs(c(:)));

return;

%-------------------------
% This is the old code.  I am afraid it was off by 1 location.  I am not
% sure what I was thinking at the time.
%
% c =[1:N];
%
% % The list in list exceeds the folding frequency.
% lst = (c > ((N/2) + 1));
%
% % We move the entries above the folding frequency down to the negative
% % frequency domain.
% c(lst) = c(lst) - N;
%
% % Then we return the sorted lst, which contains 0, (DC) near the middle.
% fList = sort(c) - 1;
%
% % The largest frequency term is positive and we normalize the list to run
% % from -1 (or close to it) up to 1.
% fList = fList/(max(fList));


%-------------------------------
% This is how we Figured it out.
% Where is the DC term?  For N=10 or N=11 the DC term is in position 6.
% So, if N is even the DC is in N/2 + 1.  If N is odd the entry is in
% (N+1)/2.
% figure;
% N = 10;
% N = 11;
% s = ones(N,N);
% figure(1); mesh(abs(fftshift(fft2(s))))

% You can try it with 1D, too.  Same story when you compare even and odd
% values.
% figure(1);
% N = 10;
% N = 11;
% N = 20;    % Peak at 11
% N = 21;    % Peak at 11
% s = ones(1,N);
% plot(abs(fftshift(fft(s))))


