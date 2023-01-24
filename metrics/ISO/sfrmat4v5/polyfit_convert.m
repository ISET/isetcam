function retval = polyfit_convert(p2, x) 
% Convert scaled polynomial fit vector to unscaled version  
%  
% p1 = polyfit(x,y,n); 
% [p2,S,mu] = polyfit(x,y,n); 
% p3 = polyfit_convert(p2); 
%   
% Peter Burns 5 June 2019
%             Based on a post by Wilburt van Hamm on Google Groups

n = numel(p2)-1; 
m = mean(x); 
s = std(x); 

retval = zeros(size(p2)); 
for i = 0:n 
  for j = 0:i 
     retval(n+1-j) = retval(n+1-j) + p2(n+1-i)*nchoosek(i, j)*(-m)^(i-j)/s^i; 
  end 
end