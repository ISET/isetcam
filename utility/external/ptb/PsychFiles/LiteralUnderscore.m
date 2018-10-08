function str = LiteralUnderscore(instr)
% str =  LiteralUnderscore(instr)
%
% Some Matlab printing and plotting routines treat an
% underscore as an instruction to subscript the next
% character.  Calling this routine inserts a "\" before
% any "_" in the passed string, so that it will come
% out as passed.
%
% SEE ALSO texlabel

% 10/28/97  dhb     LiteralUnderscr: Wrote it.
% 02/17/97  dgp     LiteralUnderscore: new name.
% 10/21/11  dcn     Now a oneliner, strrep does the job

str = strrep(instr,'_','\_');
