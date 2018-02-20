function ffwd(H)
%FFWD Fast forward movie in movie player

feval(H.fcns.ffwd,[],[],H.hfig);
