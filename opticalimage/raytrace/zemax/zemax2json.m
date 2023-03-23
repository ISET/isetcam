function [ jsonFile, info, metadata ] = zemax2json( lensName )
% Read optics parameters from Zemax (OpticsStudio) into a Matlab struct for ISET3d/Lens
%
% Inputs
%   lensName - The lens should be in \API\Matlab and ZOS format
%
% Outputs
%   jsonFile - File used by ISET3D/Lens
%   info - Struct used to write out the json file (jsonwrite(fname,info))
%   metadata - struct with f-number, film distance and focal length
%
% Example:
%   [jsonFile, info, metadata] = zemax2json('wideAngleLens.zos');
%   jsonFile = zemax2json('dgaussModelCorrect.zos');
%
if ~exist('lensName', 'var')
    error('Lens name required.');
end

% Initialize the OpticStudio connection
TheApplication = InitConnection();
if isempty(TheApplication)
    % failed to initialize a connection
    error('Could not initialize Optics Studio connection');
else
    try
        [jsonFile, info, metadata] = BeginApplication(TheApplication, lensName);
        CleanupConnection(TheApplication);
    catch err
        CleanupConnection(TheApplication);
        rethrow(err);
    end
end
end

function [jsonFile, info, metadata] = BeginApplication(TheApplication, lensName)
% Read the lens file and write the JSON file needed by ISET3D/Lens
%
% Input
%   TheApplication - Optics Studio object
%   lensName - a ZOS lens file.  It should be in the folder
%              ...\API\Matlab directory.
%
% Example
%  BeginApplication(zemax,lensName)
%  dgaussModelCorrect.zos
%  wideAngleLens.zos
%

import ZOSAPI.*;

% Creates a new API directory
apiPath = char(System.String.Concat(TheApplication.SamplesDir, '\API\Matlab'));
if ~(exist(apiPath,'dir')), error('Please make API\Matlab and put the lens file there.'); end
lensFile = fullfile(apiPath,lensName);

% Open file: matlab will open a copy of zemax through this line
if ~exist(lensFile,'file')
    error('The lens file %s cannot be found in API\Matlab.\n',lensFile);
end

% Set up primary optical system
TheSystem = TheApplication.PrimarySystem;
% sampleDir = TheApplication.SamplesDir;

% Load the lens file
TheSystem.LoadFile(lensFile,false);

% Get Surfaces
TheLDE = TheSystem.LDE;   % Lens design data
TheMFE = TheSystem.MFE;   % Merit function
nsur = TheLDE.NumberOfSurfaces;
for ii = 1:(nsur -2)
    sur = TheLDE.GetSurfaceAt(ii);
    thickness = sur.Thickness;
    if (ii == nsur-2)
        thickness = 0; % to be consistent with json created in isetrtf
    end
    radius = sur.Radius;
    if (isinf(radius))
        radius = 0;
    end
    % Index of refraction
    ior = TheMFE.GetOperandValue(ZOSAPI.Editors.MFE.MeritOperandType.INDX, ii, 1,0,0,0,0,0,0);
    
    semi_aperture = sur.SemiDiameter;
    conic_constant = [];
    surf(ii) = struct("radius", radius, "thickness", thickness, "ior", ior, "semi_aperture", semi_aperture, "conic_constant", conic_constant);
end

% Show the user the current status
TheSystem.GetCurrentStatus()

% Create strings for the description and name
[p,name,~] = fileparts(lensName);
type = "multi element lens";

% Describe the lens
FOD = TheLDE.GetFirstOrderData();
focalLength = FOD(1);
fNumber = TheMFE.GetOperandValue(ZOSAPI.Editors.MFE.MeritOperandType.WFNO, 0, 0,0,0,0,0,0,0);
filmDistance = TheLDE.GetSurfaceAt(nsur-2).Thickness;
description = sprintf('f# %.2f, fLength %.2f filmDist %.2f',fNumber,focalLength,filmDistance');

%     metadata = struct("focalLength", focalLength, "fNumber", fNumber, "filmdistance", filmdistance);
%     info = struct("name", name, "description", description, "type", type, "surfaces", surf, "metadata", metadata);
info = struct("name", name, "description", description, "type", type, "surfaces", surf);

% The stored JSON file used by ISET3D/Lens
jsonFile = fullfile(p,[name,'.json']);
jsonwrite(jsonFile, info);

% Convenient.
metadata.focalLength = focalLength;
metadata.fNumber = fNumber;
metadata.filmdistance = filmDistance;

end

function app = InitConnection()

import System.Reflection.*;

% Find the installed version of OpticStudio.
zemaxData = winqueryreg('HKEY_CURRENT_USER', 'Software\Zemax', 'ZemaxRoot');
NetHelper = strcat(zemaxData, '\ZOS-API\Libraries\ZOSAPI_NetHelper.dll');
% Note -- uncomment the following line to use a custom NetHelper path
% NetHelper = 'C:\Users\SCIENlab\Documents\Zemax\ZOS-API\Libraries\ZOSAPI_NetHelper.dll';
% This is the path to OpticStudio
NET.addAssembly(NetHelper);

success = ZOSAPI_NetHelper.ZOSAPI_Initializer.Initialize();
% Note -- uncomment the following line to use a custom initialization path
% success = ZOSAPI_NetHelper.ZOSAPI_Initializer.Initialize('C:\Program Files\OpticStudio\');
if success == 1
    LogMessage(strcat('Found OpticStudio at: ', char(ZOSAPI_NetHelper.ZOSAPI_Initializer.GetZemaxDirectory())));
else
    app = [];
    return;
end

% Now load the ZOS-API assemblies
NET.addAssembly(AssemblyName('ZOSAPI_Interfaces'));
NET.addAssembly(AssemblyName('ZOSAPI'));

% Create the initial connection class
TheConnection = ZOSAPI.ZOSAPI_Connection();

% Attempt to create a Standalone connection

% NOTE - if this fails with a message like 'Unable to load one or more of
% the requested types', it is usually caused by try to connect to a 32-bit
% version of OpticStudio from a 64-bit version of MATLAB (or vice-versa).
% This is an issue with how MATLAB interfaces with .NET, and the only
% current workaround is to use 32- or 64-bit versions of both applications.
app = TheConnection.CreateNewApplication();
if isempty(app)
    HandleError('An unknown connection error occurred!');
end
if ~app.IsValidLicenseForAPI
    HandleError('License check failed!');
    app = [];
end

end

function LogMessage(msg)
disp(msg);
end

function HandleError(error)
ME = MException('zosapi:HandleError', error);
throw(ME);
end

function  CleanupConnection(TheApplication)
% Note - this will close down the connection.

% If you want to keep the application open, you should skip this step
% and store the instance somewhere instead.
TheApplication.CloseApplication();
end


