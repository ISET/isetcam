function T = WlsToT(wls,sd)
% T = WlsToT(wls,[sd])
%
% Produce the identity color matching matrix associated
% with the passed wavelength sampling.
%
% Arguments may be either [start delta n] description or
% a list of wavelengths.
%
% The second input sd is the standard deviation of a Gaussian
% blur function which may be incorporated into the T matrix
% if desired.
%
% This second feature should be used with some
% caution, as I haven't thought it completely through.  The
% current implementation normalizes each row of T so that the
% entries sum to 1.  This seems as if it is what we want to
% get answers consistent with what we get when we don't
% incorporate wavelength blurring.
%
% 7/11/03  dhb  A few comments added.

% Force into wavelength representation.
wls = MakeItWls(wls);

[m, n] = size(wls);
if nargin == 1
    T = eye(m,m);
else
    T = zeros(m,m);
    for i = 1:m
        T(i,:) = NormalPDF(wls,wls(i),sd^2)';
        T(i,:) = T(i,:) / sum(T(i,:)');
    end
end
