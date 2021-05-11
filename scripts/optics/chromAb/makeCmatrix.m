function Cmatrices = makeCmatrix(otf, receptor, monitorSPD)
%
%  Compute the Cmatrix for each spatial resolution from otf, receptor
%  sensitivity, and monitor SPD.
%
%  Cmatrices = makeCmatrix(otf, receptor, monitorSPD)
%


% The rows of otf correspond to different spatial frequencies in cpd units.
% The first row is 0 cpd.
maxSF = size(otf, 2) - 1;

Cmatrices = zeros(9, maxSF+1);
% For each spatial frequency, scale the SPD with the appropriate otf first,
% then multiply with receptor sensitivity to get the Cmatrix.
% Each Cmatrix is then reshaped as a single column with 9 elements, and
% put together in Cmatrices.
for f = 1:(maxSF + 1)
    Cmatrices(:, f) = reshape(receptor'*diag(otf(:, f))*monitorSPD, 9, 1);
end
