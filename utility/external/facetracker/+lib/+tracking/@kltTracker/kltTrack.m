% KLT_TRACK  Track features using KLT tracker
%   [tc,P] = klt_track(tc,P,I,M,Pp) tracks features P to image I and returns
%   updated features and tracking context. M specifies a mask of pixels to
%   consider. tc and P must have been previously initialized by a call to
%   KLT_SELFEATS. Pp specifies predicted locations of features, for example
%   after compensation for global motion. If omitted, P is used.
%
%   P is a 3 x nfeats matrix with columns [x ; y ; status]. See KLT_INIT.M
%   for status codes. Features which are lost can be replaced by calling
%   KLT_SELFEATS.
%
%   A typical run of the tracker consists of:
%
%   tc = klt_init;
%   [tc,P]=klt_selfeats(tc,img{1},mask{1});
%   Q(:,:,1)=P;
%   for f=2:nframes
%       [tc,P]=klt_track(tc,P,img{f},mask{f});
%       [tc,P]=klt_selfeats(tc,img{f},mask{f},P);
%       Q(:,:,f)=P;
%   end
%
%   See also KLT_INIT, KLT_SELFEATS, KLT_PARSE.

function [tc,P] = kltTrack(obj,tc,P,I,M,Pp)

oldpyr=tc.pyramid;
tc.pyramid=obj.kltPyramid(tc,I);

if isempty(Pp)
    Pp=P;
end

if isempty(M)
    P=obj.kltMexTrack(tc,oldpyr,P,Pp);
else
    M = double(M);
    M=conv2(ones(2*tc.winsize+1,1),ones(1,2*tc.winsize+1),M,'same')==(2*tc.winsize+1)*(2*tc.winsize+1);
    P=obj.kltMexTrack(tc,oldpyr,P,Pp,M);
end
