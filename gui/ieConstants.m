function val = ieConstants(con)
%Return values of physical constants used by ISET. 
%
%      val = ieConstants(constantName)
%
% We return values of various physical constants using this function,
% rather than a global.  This will help with compilation of the Matlab
% code.  The currently stored constants are
%
%      {'planck','h','plancksconstant'}
%      {'q','electroncharge'}
%      {'c','speedoflight'}
%      {'j','joulesperkelvin','boltzman'}
%
% Example:
%   ieConstants('electron charge')
%   ieConstants('plancks constant')
%   vcConstants('joules per kelvin')
%
% Copyright ImagEval Consultants, LLC, 2003.

con = ieParamFormat(con);

switch lower(con)
    case {'planck','h','plancksconstant'}
        val =  6.626176e-034 ;
    case {'q','electroncharge'}
        val = 1.602177e-19; 		    % [C]
    case {'c','speedoflight'}
        val = 2.99792458e+8;            % Meters per second
    case {'j','joulesperkelvin','boltzman'}
        val  = 1.380662e-23;	        % [J/K], used in black body radiator formula
    case {'mmperdeg'}
        % Should eliminate, really.
        val = 0.3;
        
    otherwise
        error('Unknown physical constant');
end

return;

% Other possible constants.
%
% % frequency of visible lights (370nm - 730nm) : 
% vcConstants.nu = 3e8./((370:730)'*1e-9);        % [1/s]
% 
% % energy of photons in visible range :
% vcConstants.h_nu = 6.62e-34.*vcConstants.nu; 	 % [J]
% 
% % Room Temperature : 
% vcConstants.T= 300; 			         % [K]
% 

