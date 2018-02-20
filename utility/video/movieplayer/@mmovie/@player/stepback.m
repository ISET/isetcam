function stepback(H)
%STEPBACK Step back one frame of movie in movie player

feval(H.fcns.step_back,[],[],H.hfig);
