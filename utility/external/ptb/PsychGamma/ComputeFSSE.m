function rmse = ComputeFSSE(data,predict)
% rmse = ComputeFSSE(data,predict)
%
% Compute a root fractional SSE between data and prediction.
% Inputs should be column vectors.
% Actual code is:
%   diff = predict-data;
%   rmse = sqrt((diff'*diff)/(data'*data));
%
% 7/9/14  dhb  Wrote this.  Will replace calls to old and badly named ComputeRMSE 
%              with calls to this.  This does what ComputeRMSE did, but the
%              bad name of ComputeRMSE was bugging me too much.

diff = predict-data;
rmse = sqrt((diff'*diff)/(data'*data));
