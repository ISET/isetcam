function [sqri, hCSF] = ieSQRI(sf, dMTF, L, varargin)
% Returns the Barten SQRI value
%
%   [sqri, hCSF] = ieSQRI(sf, dMTF, L, varargin)
%
% Required input:  
%  sf   - Spatial frequency steps (cpd).  Barten uses the symbol u.
%  dMTF - The display MTF with respect to the sf values
%  L    - The display luminance in cd/m2
%
% Name/value pairs
%  width -  Angular width in degrees (default = 40 deg, which is big)
%
% Output:
%  sqri  - The Barten SQRI valkue
%  hCSF  - The human CSF calculated by the Barten formula in the 1989 paper
%
%  The SQRI formula is Equation 4 of the referenced paper.  The summation
%  is in log spacing, so sf should be logspace().  If it is in linear
%  spacing, the summation should include the 1/u term.  Not sure how to
%  check.  Maybe we should always interpolate the values to linear spacing
%  and then do the calculation as per Eq 4.
%
%  The SQRI is computed when there is an image on the display, not just for
%  the display itself. Twice the average image luminance is suggested for L
%  in the original (Equation 5b).
%  
% Reference:
%     P. G. J. Barten: J. Opt. Soc. Am. A 7 (1990) 2024.
%     
% See also:  t_ieSQRI for testing and tutorial. 
%     Replicates Figures 1-4 of the Barten (1989) and (1990) papers. 
%     
% Example
%   sf = logspace(-1.5,1.5,30);  dMTF = ones(size(sf)); L = 340/pi;
%   [s, hMTF] = ieSQRI(sf, dMTF, L);
%   [s, hMTF] = ieSQRI(sf, dMTF, L, 'width',6.5);
%   vcNewGraphWin; loglog(sf,hMTF); 
%   set(gca,'xlim',[0.01,100],'ylim',[1 1000]); grid on
%
% Copyright Imageval Consulting, LLC, 2015


p = inputParser;

vFunc = @(x) isnumeric(x) && (min(x(:)) >= 0);
p.addRequired('sf',vFunc);

vFunc = @(x) isnumeric(x) && (min(x(:)) >= 0) && (max(x(:)) - 100*eps <= 1);
p.addRequired('dMTF',vFunc);

vFunc = @(x) isnumeric(x) && (min(x(:)) >= 0);
p.addRequired('L',vFunc);

% Optional parameter of display angular width
p.addParameter('width', 40, @isnumeric);

% Check required and parse name/value in varargin
p.parse(sf,dMTF,L,varargin{:});
width = p.Results.width;

%%  Formula for human MTF
% Barten Equation 5/5a defines 1/Mt(sf).  This is the contrast sensitivity
% function.

% a = 440*(1 + (0.7/L)^(-0.2));  % Equation 5
a = 540*(1 + (0.7/L)).^(-0.2) ./ (1 + (12 ./ (width*(1 + (sf/3)).^2)));  % Equation 5a
% vcNewGraphWin; plot(sf,a)

b = 0.3*(1 + (100/L)).^0.15;
c = 0.06;

hCSF = ((a.*sf) .* exp(-b*sf) .* sqrt( 1 + c*exp(b*sf)));
% vcNewGraphWin; loglog(sf,hMTF); set(gca,'ylim',[1 1000])

% Make sure it is returned as a column
hCSF = hCSF(:);

%% Now, do the integration of the CSF and the dMTF

% The SQRI formula is
%
%   s = (1/ln(2)) * sum (dMTF(u)/hCSF(u)).^2 * (du/u)
%
% where sf is u. So, du should be the bin widths of the sf and u is the
% sf values themselves.  We will do the bins as [1,2], [2,3], ...

% The auxiliary variables for bin spacing and the 1/u term for logarithmic
% spacing, all forced to be columns.
du = diff(sf);  du = du(:);
u  = sf(2:end); u  = u(:);

% We compute the integral from the middle of the bins by averaging this
% way. 
dm = 0.5*(dMTF(1:(end-1)) + dMTF(2:end)); dm = dm(:);  % M(u)
dh = 0.5*(hCSF(1:(end-1)) + hCSF(2:end)); dh = dh(:);  % 1 / Mt(u)

% And here is the SQRI formula in Matlab notation, discretized
%
%    SQRI = 1/ln 2 * Integral (MTF(u) * CSF(u)) ^ 1/2 * (du/u)
%
sqri = 1/log(2) * sum( (dm .* dh).^(0.5) .* (du ./ u));


end


