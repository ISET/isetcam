function err=MonitorGammaError(p,x,y)
% err=MonitorGammaError(p,x,y)
% Returns mean squared error of fit of y data by MonitorGamma function of x. The
% MonitorGamma parameters are x0=p(1) and gamma=p(2). We constrain 0^2 x 0^2 1 and
% gamma^3 0, and augment the error when they are out of bounds, so that minimization
% will always settle on in-bound values.
%
% Denis Pelli 5/26/96

d=0;
if p(1)<0
	d=p(1).^2;
	p(1)=0;
end
if p(1)>1
	d=(p(1)-1)^.2;
	p(1)=1;
end
if p(2)<0
	d=d+p(2).^2;
	p(2)=0;
end
err=MonitorGamma(x,p(1),p(2))-y;
err=mean(mean(err.^2))+d;
