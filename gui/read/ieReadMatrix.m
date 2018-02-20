function mat = ieReadMatrix(defMatrix,fmt,prompt)
%Enter values of a matrix
%
%  mat = ieReadMatrix(defMatrix,[fmt],[prompt])
%
% The user  types in a set of matrix entries for a matrix of the size of
% the default matrix, defMatrix. If this is not passed in then, the
% defMatrix = eye(3). 
%
% Example:
%    d = ieReadMatrix(zeros(3,3));
%    d = diag(ieReadMatrix(ones(1,3),'  %.2f',' Enter peak [0,1]'));
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('defMatrix'), defMatrix = eye(3);           end
if ieNotDefined('fmt'),       fmt = '   %.2e';              end
if ieNotDefined('prompt'),    prompt={'Enter the matrix:'}; end

def={num2str(defMatrix,fmt)};
dlgTitle='Matrix Reader';
lineNo=size(defMatrix,1);
ReSize = 'on';
answer=inputdlg(prompt,dlgTitle,lineNo,def,ReSize);

if isempty(answer) 
    mat = [];
    return;
else
    mat = str2num(answer{1});
end

if (size(mat) ~= size(defMatrix))
    warndlg('Matrix does not match requested size.  Returning null.');
    mat = [];
end

return;


