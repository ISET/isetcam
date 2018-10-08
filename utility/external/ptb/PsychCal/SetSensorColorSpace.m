function [cal, errorRet] = SetSensorColorSpace(cal, T_sensor, S_sensor,quiet)
% [cal,errorRet] = SetSensorColorSpace(cal, T_sensor, S_sensor, [quiet])
%
% Initialize the sensor color space for use in calibration.  Requires
% a calibration structure which contains the standard
% fields.  These are checked for and a message is printed if
% they are not there.
%
% Checks that wavelength sampling is consistent and splines
% if not.
%
% errorRet indicates status of the operation.
%   == 0: OK
%   == 1: Bad condition number on linear/device conversion matrix 
%
% quiet flag suppresses error messages, default 0.

% 9/13/93     dhb   Wrote it.
% 10/16/93    jms   Added optional calData arg which is freed if passed.
% 10/30/93    dhb   Added nDevices, nBases arguments.
%             dhb   Removed optional freeing.  It is a little too clever.
% 11/11/93    dhb   Re-wrote entirely in Matlab.  The C version is too clever.
% 11/17/93    dhb   Call back through new, less clever, C routines.
%             dhb   Support to store M_ambient_linear with compute vars
% 8/4/96      dhb   Converted to modern format from original DHB scheme.
% 8/21/97     dhb   Converted for structures.
% 3/10/98	  dhb	Store T_linear and S_linear.  Seems like a good idea.
%		            Remove nBasesIn, which is never used.
% 					Change nBasesOut to nPrimaryBases.
% 1/4/00      mpr   Added quiet flag to suppress display of messages I don't care about.
% 2/25/99     dhb   Fix case of SplineCmf.
% 4/5/02      dhb, ly  New calling convention.  Internal naming not updated.
% 4/23/04     dhb   Make quiet the default.
% 3/18/10     dhb   Store T_sensor, S_sensor in fields cal.T_sensor, cal.S_sensor.
%                   These are redundant with old cal.T_linear, cal.S_linear, but
%                   it's possible that deleting those will break something in
%                   some calling program.  So I'm leaving both in for the next
%                   few years.
% 4/14/15  dhb      Handle case where S_device and/or S_ambient are not
%                   passed, or are passed empty.  This has to do with
%                   maintaining forward compatibility with BrainardLab
%                   code.

if nargin < 4 || isempty(quiet)
  quiet = 1;
end

% Set no error condition
errorRet = 0;

% Fix up empty S fields that can get passed in BrainardLab land
if (~isfield(cal,'S_device') || isempty(cal.S_device))
    cal.S_device = cal.describe.S;
end
if (~isfield(cal,'S_ambient') || isempty(cal.S_ambient))
    cal.S_ambient = cal.describe.S;
end

% Extract needed fields from calibration structure
% Colorimetric
P_device = cal.P_device;
T_device = cal.T_device;
S_device = cal.S_device;
nDevices = cal.nDevices;
nPrimaryBases = cal.nPrimaryBases;
if isempty(P_device) || isempty(T_device) || isempty(S_device) || ...
        isempty(nDevices) || isempty(nPrimaryBases)
    error('Calibration structure does not contain device colorimetric data');
end

% Ambient
P_ambient = cal.P_ambient;
T_ambient = cal.T_ambient;
S_ambient = cal.S_ambient;
if isempty(P_ambient) || isempty(T_device) || isempty(S_device)
	error('Calibration structure does not contain ambient data');
end

% Check that wavelength sampling is OK, spline if not.
if CheckWls(S_device,S_ambient,quiet)
  if ~quiet
    disp('InitCal: Splining T_ambient to match T_device');
  end
  T_ambient = SplineCmf(S_ambient,T_ambient,S_device);
end
if CheckWls(S_device,S_sensor,quiet)
  if ~quiet
    disp('InitCal: Splining T_sensor to match T_device');
  end
  T_sensor = SplineCmf(S_sensor,T_sensor,S_device);
end

% Compute conversion matrix between device and linear coordinates
M_tmp = M_TToT(T_device,T_sensor);
M_device_linear = M_tmp*P_device;

% Pull out only requested nDevices columns of M_device_linear.
% This is a simple way to define a matrix that maps to device
% space.  More sophisticated methods are possible, which is 
% why we carry the nBasesIn variable around.   
tmp_M_device_linear = M_device_linear(:,1:nDevices);
[m,n] = size(tmp_M_device_linear);
if (cond(tmp_M_device_linear) > 1e7) || (m > n)
  errorRet = 1;
  M_linear_device = pinv(tmp_M_device_linear);
elseif n > m
  errorRet = 2;
  M_linear_device = pinv(tmp_M_device_linear);
else
  M_linear_device = inv(tmp_M_device_linear);
end

% Convert ambient to linear color space
[M_ambient_linear] = M_TToT(T_ambient,T_sensor);
ambient_linear = M_ambient_linear*P_ambient;

% Put in the computed values
cal.T_sensor = T_sensor;
cal.S_sensor = S_sensor;
cal.T_linear = T_sensor;
cal.S_linear = S_sensor;
cal.M_device_linear = M_device_linear;
cal.M_linear_device = M_linear_device;
cal.M_ambient_linear = M_ambient_linear;
cal.ambient_linear = ambient_linear;
