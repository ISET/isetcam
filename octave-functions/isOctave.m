% Test if running in Octave

% This function will be called whenever code differs between 
% Matlab and Octave, with the goal to extend ISET support 

function retval = isOctave
  persistent cacheval;
  if isempty (cacheval)
    cacheval = (exist ("OCTAVE_VERSION", "builtin") > 0);
  end
  retval = cacheval;
end


