%	Book equation of dct
%
%\begin{equation}
%P(u,v) =
%  \frac {4 c(u) c(v) }{ n ^ 2}
%   \sum_{j = 0}^{n-1}
%     \sum_{k=0}^{n-1} p(j,k)
%       \cos ( \frac{(2j + 1) u \pi}{2n} ) \cos ( \frac{ (2k+1)v \pi}{2n} )
%\label{e6:dct}
%\end{equation}
%\begin{equation}
%c ( w  ) =  \left
%   \{ \begin{array}{ll}
%     { 1 / \sqrt{2} } & \mbox{if w = 0 } \\
%     { 1 } & {\mbox{otherwise}}
%    \end{array}
%   \right.
%\end{equation}
%
%	Make the dct Matrix
%
n = 8;
c = [ 1/sqrt(2) 1 1 1 1 1 1 1 ];
j = 0:n-1;
dctMatrix = zeros(n,n);
for u = 0:n-1
    dctMatrix(u+1,:) = (2*c(u+1) / n)* cos( (2*j+1) * u * pi / (2*n));
end
idctMatrix = 4*dctMatrix';
save dctMatrix dctMatrix idctMatrix
