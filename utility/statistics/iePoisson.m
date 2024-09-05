function [val, seed] = iePoisson(lambda, varargin)
% Create a matrix of Poisson samples using rate parameters in lambda
%
% Syntax:
%   [val, seed] = iePoisson(lambda, [varargin])
%
% Description:
%    Create a matrix of Poisson samples using rate parameters in lambda
%
%    The lambda (rate parameter) can be a scalar and you can request
%    multiple samples (nSamp) or it can be a matrix of rate parameters.
%
%    The noiseflag {'random' or 'frozen'} determines whether to generate a
%    new noise seed or to set the noise seed to a fixed value (default is
%    1).
%
% Inputs:
%    lambda   - The rate parameter. A matrix or a scalar. 
%    varargin - (Optional) An array of variable length containing possible
%               key/value pairs of arguments. For some of the options, see
%               the key/values section below.
%
% Outputs:
%    val      - The returning matrix.
%    seed     - The noise seed number.
%
% Optional key/value pairs:
%	 nSamp     - The number of samples
%    noiseFlag - Used to determine whether or not to generate a new noise
%                seed (or set to a fixed value.) The options are 'frozen'
%                or 'random. Default is 'random'.
%    seed      - The noise seed number. Default is 1.
% References:
%    Knuth routine - found on a web-page reference and also at
%       http://en.wikipedia.org/wiki/Poisson_distribution
%       http://www.columbia.edu/~mh2078/MCS04/MCS_generate_rv.pdf
%

% History:
%    xx/xx/10       Copyright ImagEval, LLC, 2010
%    06/03/15  xd   iePoissrnd now uses a randomly generated seed
%    06/04/15  xd   added flag to determine if noise should be frozen
%    01/24/17  npc  Now checking first for Statistics Toolbox, and using 
%                   poissrnd if it exists. If not it uses the local
%                   equivalent, iePoissrnd
%    01/25/17  npc  Now only using poissrnd from the Statistics Toolbox.
%    12/13/17  jnm  Formatting
%    01/24/18  jnm  Formatting update to match Wiki

% Examples:
%{
    % Matrix form
	nSamp = 128; 
    lambda = round(rand(nSamp, nSamp) * 10);
	tic, val = iePoisson(lambda); toc
	vcNewGraphWin;
	subplot(2, 1, 1), imagesc(lambda);
    colormap(gray);
    colorbar;
    axis image
	subplot(2, 1, 2), imagesc(val); 
    colormap(gray);
    colorbar;
    axis image
%}
%{
	% Multiple samples form
	lambda = 4;
    nSamp = 1000;
    val = iePoisson(lambda, 'nSamp', nSamp);
	vcNewGraphWin;
    hist(val, 50)
%}
%{
    % Frozen noise
	lambda = 4;
    nSamp = 1; 
	val1 = iePoisson(lambda, 'nSamp', nSamp, 'noiseFlag', 'frozen')
%}
%{
    % Return seed
    nSamp = 128; 
    lambda = round(rand(nSamp, nSamp) * 10);
	[val, seed] = iePoisson(lambda, 'nSamp', nSamp, 'noiseFlag', 'random');
%}

%% Parse parameters
p = inputParser;

% Required
p.addRequired('lambda', @isnumeric);

% Key/value
p.addParameter('nSamp', 1, @isnumeric);
vFunc = @(x)(ismember(x, {'random', 'frozen', 'donotset'}));
p.addParameter('noiseFlag', 'random', vFunc);
p.addParameter('seed', 1, @isnumeric);
p.parse(lambda, varargin{:});

nSamp = p.Results.nSamp;
noiseFlag = p.Results.noiseFlag;
seed = p.Results.seed;

switch noiseFlag
    case 'frozen'
        rng(seed);
    case 'random'
        seed = rng;
end

if isscalar(lambda)
    val = poissrnd(lambda, nSamp);
else
    val = poissrnd(lambda);
end
       
end