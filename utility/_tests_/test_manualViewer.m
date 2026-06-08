function tests = test_manualViewer()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% Validate web page viewer for manuals
%
%

%%
ieInit;

%%
ieManualViewer('isetcam wiki')

disp('Try the individual pages that are in v_icam_manualViewer')

%{
% Tutorials
ieManualViewer('iset functions')

% Scene
ieManualViewer('scene functions')

% OI/optics
ieManualViewer('oi functions')
ieManualViewer('optics functions')

ieManualViewer('sensor functions')
ieManualViewer('pixel functions')

ieManualViewer('ip functions')
ieManualViewer('metrics functions')
%}
%%
end
