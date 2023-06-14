% Replicate the published curves in
%
%   Computing human optical point spread functions
%   A.B. Watson (2015), JOV
%
% See also
%

wvf = wvfCreate;
zIndices = [2,2; 2,0;  2,2; 3,-3; ...
    3,-1; 3, 1; 3, 3; 4, -4; ...
    4,-2; 4, 0; 4, 2; 4, 4];

zValues = [-0.0946, 0.0969, 0.305,0.0459,...
    -0.121, 0.0264, -0.113, 0.0282,...
    0.03, 0.0294, 0.0163, 0.064];

for idx = 1:numel(zValues)
    j = wvfZernikeNMToOSAIndex(zIndices(idx,1),zIndices(idx,2));
    % wvfSet(wvf, 'zcoeffs', val, jIndex);
    wvf = wvfSet(wvf,'zcoeffs',zValues(idx),j);
    wvf.zcoeffs
end
