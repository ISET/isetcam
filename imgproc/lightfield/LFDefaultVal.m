% LFDefaultVal - Convenience function to set up default parameter values
% 
% Usage: 
% 
%   Var = LFDefaultVal( Var, DefaultVal )
% 
% 
% This provides an elegant way to establish default parameter values. See LFDefaultField for setting
% up structs with default field values.
%
% Inputs:
% 
%   Var: string giving the name of the parameter
%   DefaultVal: default value for the parameter
%
% 
% Outputs:
% 
%   Var: if the parameter already existed, the output matches its original value, otherwise the
%        output takes on the specified default value
% 
% Example: 
% 
%   clearvars
%   ExistingVar = 42;
%   ExistingVar = LFDefaultVal( 'ExistingVar', 3 )
%   OtherVar = LFDefaultVal( 'OtherVar', 3 )
% 
%   Results in :
%       ExistingVar =
%           42
%       OtherVar =
%            3
%
% Usage for setting up default function arguments is demonstrated in most of the LF Toolbox
% functions.
% 
% See also: LFDefaultField

% Part of LF Toolbox v0.4 released 12-Feb-2015
% Copyright (c) 2013-2015 Donald G. Dansereau

function Var = LFDefaultVal( Var, DefaultVal )

CheckIfExists = sprintf('exist(''%s'', ''var'') && ~isempty(%s)', Var, Var);
VarExists = evalin( 'caller', CheckIfExists );

if( ~VarExists )
    Var = DefaultVal;
else
    Var = evalin( 'caller', Var );
end

end