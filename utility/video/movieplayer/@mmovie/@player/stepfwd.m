function stepfwd(H)
%STEPFWD Step forward one frame of movie in movie player

feval(H.fcns.step_fwd,[],[],H.hfig);
