function roi = ieRoiCreate(varargin)
% Create an ROI struct
%
% Syntax
%   roi = ieRoiCreate(varargin)
%
% Description
%   We are starting to create and show more ROIs, storing them in the ip,
%   sensor, oi, and scene windows.  This is just the initial development of
%   that code.
%
%   Also, we need to do some more work integrating all of the ROI functions
%   in the gui/roi directory.  There will be an ieRoiSet/Get/Plot
%
% Inputs
%
% Optional key/value pairs
%
% Returns
%   roi - a struct, though maybe it will become an roi class
%
% Wandell, January 25 2020
%
% See also
%    vcROISelect; ieROIDraw, ieRect2Locs
