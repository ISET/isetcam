% function Hout = hist2d(D,Xn,Yn,[Xlo Xhi],[Ylo Yhi])
% 
% Calculates and returns the 2 Dimensional Histogram of D. 
%
% Counts number of points in the bins defined by 
% X = linspace(Xlo,Xhi,Xn) and
% Y = linspace(Ylo,Yhi,Yn) 
%
% D must be a 2 column or 2 row matrix or an array of complex numbers
%
% [Xlo Xhi],[Ylo Yhi] are optional and default to the min and max of
% the input data
% Xn and Yn are optional and default to 20
%
% Example:
%  hist2d([randn(1,10000); randn(1,10000)])
% 
function Hout = hist2d(D,Xn,Yn,Xrange,Yrange)
% first supply optional arguments
if nargin<3
    Yn=20;
end
if nargin<2
    Xn=20;
end
if ~isreal(D)
    D=[real(D(:)) imag(D(:))];
end
    
if (size(D,1)<size(D,2) && size(D,1)>1)
    D=D.';
end
if size(D,2)~=2;
    error('The input data matrix must have 2 rows or 2 columns');
end
if nargin<4
    Xrange=[min(D(:,1)),max(D(:,1))];
end
if nargin<5
    Yrange=[min(D(:,2)),max(D(:,2))];
end
%
Xlo = Xrange(1) ; Xhi = Xrange(2) ;
Ylo = Yrange(1) ; Yhi = Yrange(2) ; 
X = linspace(Xlo,Xhi,Xn)' ;
Y = linspace(Ylo,Yhi,Yn)' ;

Dx = D(:,1) ; Dy = D(:,2) ;
n = length(D) ;

H = zeros(Yn,Xn) ;

for i = 1:n
    x = dsearchn(X,Dx(i)) ;
    y = dsearchn(Y,Dy(i)) ;
    H(y,x) = H(y,x) + 1 ;
end ;

figure , surf(X,Y,H) ;
% Xmid = 0.5*(X(1:end-1)+X(2:end)) ;
% Ymid = 0.5*(Y(1:end-1)+Y(2:end)) ;
% figure , pcolor(Xmid,Ymid,H) ; 
colorbar ; shading flat ; axis square tight ; 
if nargout>0
    Hout=H;
end
