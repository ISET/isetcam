function rewind(H)
%REWIND Skip backward in movie in movie player

feval(H.fcns.rewind,[],[],H.hfig);
