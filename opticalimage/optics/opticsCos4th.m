function oi = opticsCos4th(oi)
% Compute relative illumination for cos4th model
%
% Synopsis
%  oi = opticsCos4th(oi)
%
% Input
%  oi:
%
% Return:
%  oi - with the cos4th data attached
%
% Description
%  This routine is used for shift-invariant optics, when full ray trace
%  information is unavailable.
%
% Example:
%  Calculates how long to compute cos4th
%
%   scene = sceneCreate; oi = oiCreate;
%   oi = oiSet(oi,'offaxis method','cos4th');
%   tic, oi = oiCompute(oi,scene); toc
%   oi = oiSet(oi,'offaxis method','skip');
%   tic, oi = oiCompute(oi,scene); toc
%
% Copyright ImagEval Consultants, LLC, 2003.

optics = oiGet(oi, 'optics');

method = opticsGet(optics, 'cos4th function');
if isempty(method) || isequal(method,'cos4th')
    method = 'cos4th';
    oi = oiSet(oi, 'optics cos4th function', method);
    optics = cos4th(oi);
else
    % Calculating the  scaling factors using the user-supplied method.
    % We might check whether it exists already and only do this if
    % the cos4th slot is empty.
    optics = feval(method, optics, oi);
    % figure; mesh(optics.cos4th.value)
end

oi = oiSet(oi, 'optics', optics);

% Applying cos4th scaling.
sFactor = opticsGet(optics,'cos4th Data');  % figure(3); mesh(sFactor)
photons = bsxfun(@times, oiGet(oi, 'photons'), sFactor);

% Compress the calculated image and put it back in the structure.
oi = oiSet(oi, 'photons',photons);

end
