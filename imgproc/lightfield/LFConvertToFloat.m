% LFConvertToFloat - Helper function to convert light fields to floating-point representation
%
% Integer inputs get normalized to a max value of 1.

% Part of LF Toolbox v0.4 released 12-Feb-2015
% Copyright (c) 2013-2015 Donald G. Dansereau

function LF = LFConvertToFloat( LF, Precision )

Precision = LFDefaultVal('Precision', 'single');

OrigClass = class(LF);
IsInt = isinteger(LF);

LF = cast(LF, Precision);

if( IsInt )
	LF = LF ./ cast(intmax(OrigClass), Precision);
end
