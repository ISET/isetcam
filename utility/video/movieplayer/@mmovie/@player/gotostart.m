function gotostart(H)
%GOTOSTART Go to start of movie in movie player

feval(H.fcns.goto_start,[],[],H.hfig);
