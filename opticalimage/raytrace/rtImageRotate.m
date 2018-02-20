function Id = rtImageRotate(Is,theta)
% Obsolete
% Rotate a 2-D source image (Is) about its center by theta degrees
%
%     Id = rtImageRotate(Is,theta)
%
% Rotate a 2-D source image (Is) about its center by an angle theta (in
% degrees)to a 2-D destination image.
%	
% Copyright ImagEval Consultants, LLC, 2003.


[m n]=size(Is);

ismin=1;             %minimum source image row index
ismax=m;             %maximum source image row index
jsmin=1;             %minimum source image column index
jsmax=n;             %maximum source image column index

ic=(ismax+1)/2;      %row of rotation center
jc=(jsmax+1)/2;      %column of rotation center

% Calculate the rotation matrix
theta=theta*pi/180;  %convert degrees to radians
R=[cos(theta) -sin(theta); sin(theta) cos(theta)];  %rotation matrix
invR=inv(R);

Id=zeros(m,n);       % initialize final image

for id=1:m
   for jd=1:n
      is=invR(1,1)*(id-ic)+invR(1,2)*(jd-jc)+ic;   %source pixel row that maps to the selected destination pixel
      js=invR(2,1)*(id-ic)+invR(2,2)*(jd-jc)+jc;   %source pixel column that maps to the selected destination pixel

      if is>ismin & is<ismax & js>jsmin & js<jsmax
          Id(id,jd)=(1-(is-floor(is))) * ...
              (Is(floor(is), floor(js))*(1-(js-floor(js))) + ...
              Is(floor(is), floor(js)+1)*(js-floor(js)))   + ...
              (is-floor(is))* ...
              (Is(floor(is)+1, floor(js))*(1-(js-floor(js))) + ...
              Is(floor(is)+1, floor(js)+1)*(js-floor(js)));

      end
   end
end