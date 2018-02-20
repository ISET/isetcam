function ieString = ieSelectString(prompt,sList) 
% Query the user to select a single string from a list
%
%    newFilterName = ieSelectString(prompt,sList)     
%
% If the user cancels, the returned string is empty.
%
% Example:
%  thisString = ieSelectString('Enter filter name: ',{'a','b'})
%
% Copyright ImagEval Consultants, LLC, 2015.

if ieNotDefined('prompt'), prompt = 'Select one'; end
if ieNotDefined('sList'), error('String list is required'); end

[v, ok] = listdlg(...
    'PromptString',prompt,...
    'SelectionMode','single', ...
    'ListString',sList);

if ok, ieString = sList{v};
else   disp('Canceled'); ieString = ''; return; 
end

end