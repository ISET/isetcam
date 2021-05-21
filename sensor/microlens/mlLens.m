function [WOut,X,U] = mlLens(f,lambda,WIn,X,U,propagationType,type)
%Transform the phase-space diagram from microlens plane to the focal plane
%
%   [WOut,X,U] = mlLens(f,lambda,WIn,X,U,propagationType,type)
%
%  We define the position of the microlens by specifying the chief ray
%  angle from the source optics (in the microLensWindow).
%
%  The routine transforms the phase-space diagram in the microlens plane
%  into its representation in the focal plane (i.e., at the
%  photodetector).
%
%    X:    the range of possible spatial positions in the microlens plane
%    U:    the range of possible angles of the rays
%    WIn:  One at the locations of X and U that are within the spatial extent angular cone
%          that the microlens sees coming from the source. (to check ... it
%          may be that we define the valid range by WIn, but we allow X and
%          U to be beyond the valid range).
%
%  The transformed data, WOut, represent the modified phase-space diagram
%  in the photodetector plane (i.e. focal plane of the microlens).
%
%  The WOut and WIn values of the phase-space diagram indicate the amount of
%  energy transmitted at the position,angle values they represent.
%  WIn(X,U) -> WOut(X,U) is the Wigner transform.
%
%    f:  Focal length
%    lambda:  Wavelength for calculation
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('f'), error('Focal length required'); end
if ieNotDefined('lambda'), error('Wavelength required.'); end

switch lower(type)
    case('angle')
        k = 1;
    case('frequency')
        k = 2*pi/lambda;
end

x = X(1,:); u = U(:,1);

% Change of angle induced by lens. Does not need a correction for the
% refractive index of the outgoing medium
switch lower(propagationType)
    case('paraxial')        % ABCD (paraxial)
        % WOut = griddata(X,U,WIn,X,U+k/f*X);
        z = [X(:), U(:)+k/f*X(:)]; f = WIn(:);  % Might need to be U(:)-k*X(:)/f
        [WOut, zv] = ffndgrid(z,f,-length(x),[min(x) max(x) min(u) max(u)],1);
    case('non-paraxial')    % non-ABCD (non-paraxial)
        % WOut = griddata(X,U,WIn,X,U+k*sin(atan(X/f)));
        z = [X(:), U(:)+k*sin(atan(X(:)/f))]; f = WIn(:); % Might need to be U(:)-k*sin(atan(X(:)/f))
        [WOut, zv] = ffndgrid(z,f,-length(x),[min(x) max(x) min(u) max(u)],1);
end

% Convert from sparse to full matrix (This could be done later if we need
% save more space and time
WOut = full(WOut);
% NaNs set to 0
WOut(find(isnan(WOut))) = 0;

return;