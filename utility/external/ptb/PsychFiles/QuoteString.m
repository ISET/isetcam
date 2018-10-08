function string=QuoteString(string)
% string=QuoteString(string)
%
% Wraps a string in quotes, after doubling any embedded quotes.
% E.g. "Denis's disk" becomes "'Denis''s disk'"
% This is useful when supplying literal filenames in an eval statement.
% The quoting is necessary because the filename may contain spaces.
% The doubling is necessary because a single quote would be interpreted
% as the end of the string.

% Denis Pelli 6/6/96
% DCN, now a oneliner

quote='''';
string=[quote strrep(string,quote,[quote quote]) quote];
