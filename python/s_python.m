%% s_python
%
% We installed anaconda3 with its own installer for the Mac M1 on wandell's
% office machine.
%
% https://www.anaconda.com/
%
% After installing anaconda3, it is in ~/opt/anaconda3 and the conda
% command is available.
% 
% We updated conda using the command
%
%   conda update -n base -c defaults conda
%
% We created a py38 envrionment with the command
%
%   conda create -n py38 python=3.8  
%   conda create -n py39 python=3.9  
%
% We activated the environment with this version of python
%
%   conda activate py38  
%   conda activate py39  
%
% So then we had a py38 environment activated as a python environment,
% which you can see in the shell.
%
% At Wandell's home and office, Matlab accepted the python environment
%
% pyenv('Version','/opt/miniconda3/envs/py39/bin/python');
%
% We tested by running
%   result = py.list([1, 2, 6]);
%
%% May 8, 2024.  We updated to 3.9 using the commands above but replacing 38 with 39
%
% After installing, we need to install the libraries specified in
% requirements.txt.
%
%    pip install -r requirements.txt
%
%% May 13
%
% It seems I had an old Intel version installed. 
%
% We got the miniconda installer, and got an Apple Silicon version.  
% 
%   https://docs.anaconda.com/free/miniconda/
%
% I then created a py39 version using the conda command, as above.
%
%%
% On wandell's Mac at home, which is an Intel machine, we should do
% the same but with miniconda for the Intel architecture.
%
%   And that worked, as per above.
%
%%  Next, to run Zhenyi's code, install requirements.txt
%
