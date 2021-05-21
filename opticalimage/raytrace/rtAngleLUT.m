function angleLUT = rtAngleLUT(svPSF)
% Create LUT for angle lookup in rtPrecomputePSFApply
%
%    angleLUT = rtAngleLUT(svPSF)
%
% The svPSF is precomputed to contain PSFs for different eccentricities and
% sample angles.
%
% This routine creates a LUT that maps angles at the 1 deg step size in the
% image plane into a matrix with 360 rows and two columns.  The columns are
%
%  * an index to the svPSF sample angles, and
%  * a weight for that index.
%
% In more detail: the first column contains the integer value of an svPSF
% sample angle.  The second column contains the weight that should be used
% for that particular sample. Implicitly, 1 - weight should be used for the
% interpolation to the next higher sample.
%
% The weight is a number between 1/angSteps and 1.0.
%
% Example:
%    oi = vcGetObject('oi'); angSteps = 15;
%    svPSF = rtPrecomputePSF(oi,angSteps);
%    angleLUT = rtAngleLUT(svPSF);
%    vcNewGraphWin; plot(1:360,angleLUT(:,1),'-')
%    plot(1:(2*angSteps),angleLUT(1:(2*angSteps),2),'-')  % Just the first two
%
% Copyright ImagEval Consultants, LLC, 2009.

% NOTE:
% Some day we might apply this to the optics structure and use sets/gets.
% At present, we don't ahve sets and gets for the svPSF. The
% svPSF.sampAngles variable might change name - that would be annoying.

if ieNotDefined('svPSF'), error('Precomputed svPSF required'); end


angleLUT = zeros(360,2);        % Lower index and its weight
angSteps = svPSF.sampAngles(2) - svPSF.sampAngles(1);

for ii=1:360
    [val,idx1] = min( abs(ii - svPSF.sampAngles));
    
    if ii > svPSF.sampAngles(idx1)
    else
        idx1 = idx1 - 1;
        val = angSteps - val;
    end
    angleLUT(ii,:) = [idx1,val/angSteps];
end

return

