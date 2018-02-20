function gotoend(H)
%GOTOEND Skip to end of movie in movie player

feval(H.fcns.goto_end,[],[],H.hfig);
