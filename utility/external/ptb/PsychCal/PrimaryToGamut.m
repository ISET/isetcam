function [gamut, badIndex] = PrimaryToGamut(cal,primary)
% [gamut, badIndex] = PrimaryToGamut(cal,primary)
%
% Check that primary coordinates are in range [0,1].
% Force them to be so if not.  The indices of the
% out of gamut primary settings are returned as 'badIndex'.
%
% 9/8/93    jms   Set global flag if there was a gamut problem.
% 9/13/93   jms   Took out the global flag and instead return
%                 a flag vector for the ones that were changed.
% 9/26/93	  dhb   Added calData argument.  It is not used, but
%                 I want to pass it through these routines generally
% 9/27/93   jms   Commented out the messages for going out of gamut.
%	3/7/94		dhb		Modified so that badIndex return respects tolerance.
% 4/5/02    dhb, ly  New naming convention.

gamut = primary;
tolerance = 1e-10;

[m,n] = size(primary);
badIndex = zeros(1,n);

% Check lower bound by rows
for (i=1:m)
  index = find(primary(i,:) < 0);
  if (~isempty(index))
    gamut(i,index) = zeros(1,length(index));
		index = find(primary(i,:) < -tolerance);
		if (~isempty(index))
			badIndex(index) = ones(1,length(index));
		end
  end
end


% Check upper bound by rows
for (i=1:m)
  index = find(primary(i,:) > 1);
  if (~isempty(index))
    gamut(i,index) = ones(1,length(index));
		index = find(primary(i,:) > 1+tolerance);
		if (~isempty(index))
    	badIndex(index) = ones(1,length(index));
		end
  end
end
