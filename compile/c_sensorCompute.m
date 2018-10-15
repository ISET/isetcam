function rgb = c_sensorCompute()
% Create code to compile for producing a sensor output data file
%
% c_sensorCompute
%
% We successfully compiled once using restoredefaultpath and then running.
% The output is a run_c_sensorCompute.sh file.
% That one executes by 
%      run_c_sensorCompute.sh $MCROOT, where on the GCP $MCROOT is
%     ./run_c_sensorCompute.sh /software/MATLAB/R2017b
%
% But in that case it complained it couldn't find the sceneCreate function.
% Why is that?
%
% When we run with everything on the path and no restoredefaultpath, the
% compiler generates a warning about finding things.  But it does seem to
% find stuff.  What fails on is finding data files, like luminosity.mat.
%
% The next problem, then, is that the compiled code doesn't know where the
% data/human/luminosity.mat file is.
% 
% EXAMPLE COMPILATION:
%     git clone https://github.com/ISET/isetcam
%
%     In Matlab (e.g., r2015b):
%       mcc -m isetcam/compile/c_sensorCompute.m -I isetcam
%

scene = sceneCreate;
oi = oiCreate;
oi = oiCompute(oi,scene);
sensor = sensorCreate;
sensor = sensorCompute(sensor,oi);
rgb = sensorGet(sensor,'rgb');
save('sensor1','rgb');

end

%%