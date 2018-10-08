function [fit_out,x,err] = FitGammaWeib(values_in,measurements,values_out,x0)
% [fit_out,x,err] = FitGammaWeib(values_in,measurements,values_out,x0)
%
% Fits a Weibull function to the passed gamma data.
%
% 10/3/93   dhb  	Created from jms code to fit psychometric functions
% 3/4/05	dhb	    Conditionals for optimization toolbox version.
% 			dhb		Encapsulate error calculation
% 8/2/15    dhb   Update calls to exist to work when query is for a p-file.

% Bounds
vlb = [1e-5 1e-5]';
vub = [1e5  10.0]';

% Check for needed optimization toolbox, and version.
if (exist('fmincon','file'))
	options = optimset;
	options = optimset(options,'Diagnostics','off','Display','off');
	options = optimset(options,'LargeScale','off');
	x = fmincon('FitGammaWeibFun',x0,[],[],[],[],vlb,vub,[],options,values_in,measurements);	
elseif (exist('constr','file'))
	options = foptions;
	options(1) = 0;
	options(14) = 600;
	x = constr('FitGammaWeibFun',x0,options,vlb,vub,[],values_in,measurements);
else
	error('FitGammaWeib requires the optional Matlab Optimization Toolbox from Mathworks');
end

% Now compute fit values and error to data for return
fit_out = ComputeGammaWeib(x,values_out);
err = FitGammaWeibFun(x,values_in,measurements);
