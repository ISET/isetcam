function Xscaled = ieScaleColumns(X, b1, b2)
% Call the ieScale function on each column of the input
%
%  Xscaled = ieScaleColumns(X,b1,b2)
%
% Description
%   Call ieScale on each column of X.
%
% Inputs
%   X - a matrix
%   b1
%   b2
%
%
% JEF/BW Vistasoft team 2018
%
% See also
%   ieScale

%% Parameter
if notDefined('b1'), b1 = 1; end
if notDefined('b2'), b2 = []; end

%%
if isempty(b2)
    Xscaled = zeros(size(X));
    for ii = 1:size(X, 2)
        Xscaled(:, ii) = ieScale(X(:, ii), b1);
    end
else
    Xscaled = zeros(size(X));
    for ii = 1:size(X, 2)
        Xscaled(:, ii) = ieScale(X(:, ii), b1, b2);
    end
end

end
