function [spec_out] = SplineRaw(wls_in, spec_in, wls_out, extend)
% [spec_out] = SplineRaw(wls_in, spec_in, wls_out, [extend])
%
% Convert the wavelength representation of a spectrum.
%
% Handling of out of range values:
%   extend == 0: Cubic spline, extends with zeros [default]
%   extend == 1: Cubic spline, extends with last value in that direction
%   extend == 2: Linear interpolation, linear extrapolation
%
% spec_in may have multiple columns, in which case spec_out does as well.
%
% wls_in and wls_out may be specified as a column vector of
% wavelengths or as a [start delta num] description.
%
% 7/26/03  dhb  Add extend argument
% 8/13/11  dhb  Added linear extrapolation option for extend

% Default value for extend
if (nargin < 4 || isempty(extend))
    extend = 0;
end

% Convert wls_in wls_out to lists if necessary
wls_in = MakeItWls(wls_in);
wls_out = MakeItWls(wls_out);

% Spline the whole enchilada
[null,n] = size(spec_in);
[m,null] = size(wls_out);
spec_out = zeros(m,n);

% I decided not to touch the way things were
% handled for extend == 0,1
switch (extend)
    case {0,1}
        % Check on
        for i=1:n
            spec_out(:,i) = spline(wls_in,spec_in(:,i),wls_out);
        end
        
        % Find range of input spectrum
        min_wl = min(wls_in);
        max_wl = max(wls_in);
        
        % Truncate to zero outsize of critical range
        if (extend)
            index = find( wls_out < min_wl);
            if (~isempty(index))
                for i=1:n
                    spec_out(index,i) = spec_in(1,i);
                end
            end
            index = find(wls_out > max_wl);
            if (~isempty(index))
                for i=1:n
                    spec_out(index,i) = spec_in(end,i);
                end
            end
        else
            index = find( wls_out < min_wl | wls_out > max_wl );
            if (length(index) ~= 0)
                spec_out(index,:) = zeros(length(index),n);
            end
        end
    case 2,
        for i=1:n
            spec_out(:,i) = interp1(wls_in,spec_in(:,i),wls_out,'linear','extrap');
        end
    otherwise
        error('Bad value passed for extend argument');
end






