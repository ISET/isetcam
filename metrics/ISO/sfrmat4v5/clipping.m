function [nlow, nhigh, status] = clipping(a, low, high, thresh1)
% [n, status] = clipping(a)
% Function checks for clipping of data array
% a = array
% low = low clip value
% high = high clip value
% thresh1 = threshhold fraction used for warning, if =0 all
%           clipping is reported
% Peter Burns 10 Aug. 1999
%             30 Sept 2002 remove warning dialog window
% 
status = 1;

[nlin npix ncol] = size(a);
n = nlin*npix;

nhigh = zeros(ncol, 1);
nlow =  zeros(ncol, 1);

for k = 1: ncol;
   for j = 1: npix;
      for i = 1: nlin;
if a(i, j, k) <= low;
   nlow(k) = nlow(k) + 1;
end;
if a(i, j, k) >= high;
   nhigh(k) = nhigh(k) + 1;
end;

end;
end;
end;

nhigh = nhigh./n;

for k =1: ncol;
 if nlow(k) > thresh1;
  disp([' *** Warning: low clipping in record ', num2str(k)]);
  status = 0;
  end;
 if nhigh(k) > thresh1;
  disp([' *** Warning: high clipping in record ', num2str(k)]);
  status = 0;
 end;
end;

nlow = nlow./n;
if status ~= 1
% hh =warndlg('Data clipping errors detected','ClipCheck','non-modal');
%hh = txtbox('Data clipping errors detected','ClipCheck','non-modal');

%close(hh);
end;
return;
