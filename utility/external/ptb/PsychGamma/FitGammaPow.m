function [fit_out,x,err] = FitGammaPow(values_in,measurements,values_out,x0)
% [fit_out,x,err] = FitGammaPow(values_in,measurements,values_out,x0)
%
% Fit power function to gamma data.
%
% NOTE: Uses Mathworks Optimization Toolbox.
% 
% Also see FitGamma, FitGammaDemo.
%
% 4/08/02   awi   Turned off warnings while calling constr to avoid future obsolete warning
% 3/4/05	dhb	  Conditionals for optimization toolbox version.
% 8/2/15    dhb   Fix conditionsal because fmincon is now a p file.

% Check for needed optimization toolbox, and version.
if (exist('fmincon','file'))
	options = optimset;
	options = optimset(options,'Diagnostics','off','Display','off');
	options = optimset(options,'LargeScale','off');
	x = fminunc('FitGammaPowFun',x0,options,values_in,measurements);	
elseif (exist('constr','file'))
	options = foptions;
	options(1) = 0;
	options(14) = 600;
	x = constr('FitGammaPowFun',x0,options,[],[],[],values_in,measurements);
else
	error('FitGammaPow requires the optional Matlab Optimization Toolbox from Mathworks');
end

% Now compute fit values and error to data for return
fit_out = ComputeGammaPow(x,values_out);
err = FitGammaPowFun(x,values_in,measurements);
