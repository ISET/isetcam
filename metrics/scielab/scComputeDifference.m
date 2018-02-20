function result = scComputeDifference(xyz1,xyz2,whitePt,deltaEVer)
% Compute various forms of deltaE values for a pair of XYZ images
%
%     result = scComputeDifference(xyz1,xyz2,whitePt,deltaEVer);
%
% The CIELAB deltaE metric for a pair of XYZ images depends on the white
% point and the version of delta E.  This routine takes two XYZ images
% and white point information, and computes the delta E value requested by
% the user.
%
% whitePt should either be a cell array with two white points or, if the
% two images have the same white point, whitePt can be a 3-vector.
%
% By default, deltaEVe is the CIELAB 2000 delta E (dE).  For backwards
% compatibility, it is possible to ask for earlier versions:
%  deltaEVer = '1976'; or deltaEVer = '1994';
%
% It is also possible to request the luminance, chrominance, or hue errors
% that go into the computation of the dE 2000.  This are returned if you
% ask for deltaEVer = 'chrominance' or deltaEVer = 'luminance' or deltaEVer
% = 'hue'. These components are always based on the CIELAB 2000 code. 
%
% If you would like both the deltaE and the components, you cans set
% deltaEVer to 'all'.  Then result.dE will be the deltaE and
% result.components will be a structure containing the scaled dL, dH and dC
% terms from CIELAB dE2000.
%
% Examples:
%   e = scComputeDifference(xyz1,xyz2,whitePt);            % deltaE 2000
%   e = scComputeDifference(xyz1,xyz2,whitePt,'hue');      % hue only
%   e = scComputeDifference(xyz1,xyz2,whitePt,'luminance');% luminance only
%
% Copyright Imageval 2005

if ieNotDefined('deltaEVer'), deltaEVer='2000'; end;

if ~iscell(whitePt)
    tmp{1} = whitePt; tmp{2} = whitePt;
    whitePt = tmp;
end

% Are we sure we should be clipping? Took out May 3 2012.
% xyz1 = ClipXYZImage(xyz1, whitePt{1});
% xyz2 = ClipXYZImage(xyz2, whitePt{2});

switch deltaEVer
    case {'2000','1994','1976'}
        result = deltaEab(xyz1, xyz2, whitePt, deltaEVer);

    case {'luminance','chrominance','hue'}
        [result, components] = deltaEab(xyz1, xyz2, whitePt, deltaEVer);
        if strcmpi(deltaEVer,'luminance'), result = components.dL;
        elseif strcmpi(deltaEVer,'chrominance'), result = components.dC;
        elseif strcmpi(deltaEVer,'hue'), result = components.dH;
        end
    case {'all'}
        [result.dE, result.components] = deltaEab(xyz1, xyz2, whitePt, deltaEVer);
    otherwise
        error('Unknown deltaEVer %s\n',deltaEVer);
end

return
