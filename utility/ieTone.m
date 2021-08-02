function [params,Y] = ieTone(varargin)
% Play a tone using the sound command
%   
% Synopsis
%    [params,Y] = ieTone(varargin)
%
% Input
%
% Optional key/val pairs
%   Frequency  - Default is 512 Hz
%   Amplitude  - Default is 1
%   Duration   - Default is 1 sec
%
% Output
%   Y - The tone
%   params - The parameters for this tone
%
% See also
%   sound, beep

%{
  params = ieTone;
%}
%{
  param.Frequency = 256;
  param.Amplitude = 0.2;
  param.Duration = 0.1;
  params = ieTone(param);
%}
p = inputParser;
p.addParameter('Frequency',256,@isscalar);
p.addParameter('Amplitude',0.2,@isscalar);
p.addParameter('Duration',0.25,@isscalar);
p.parse(varargin{:});

Duration = p.Results.Duration;
Frequency = p.Results.Frequency;
Amplitude = p.Results.Amplitude;

%% Create the tone

Fs = 8192;                           % Default Sampling Frequency (Hz)
Ts = 1/Fs;                           % Temporal spacing (sec)
T = 0:Ts:(Fs*Ts*Duration);           % Times
Y = Amplitude*sin(2*pi*Frequency*T); % Tone

% Play it
sound(Y,Fs); 

% Return the params
if nargout > 0
    params.Amplitude = Amplitude;
    params.Duration  = Duration;
    params.Frequency = Frequency;
end

end

