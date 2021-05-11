function txt = sceneDescription(scene)
%Text description of the scene properties, displayed in scene window
%
%    descriptionText = sceneDescription(scene)
%
% Copyright ImagEval Consultants, LLC, 2003.

if isempty(scene)
    txt = 'No scene';
else
    % txt = sprintf('**Properties**\n');

    % Row and col
    r = sceneGet(scene, 'rows');
    c = sceneGet(scene, 'cols');
    txt = sprintf('Row,Col:\t%.0f by %.0f \n', r, c);
    %     txt = addText(txt,str);

    u = round(log10(sceneGet(scene, 'height', 'm')));
    if (u >= 0), str = sprintf('Hgt,Wdth:\t(%3.2f, %3.2f) m\n', sceneGet(scene, 'height', 'm'), sceneGet(scene, 'width', 'm'));
    elseif (u >= -3), str = sprintf('Hgt,Wdth\t(%3.2f, %3.2f) mm\n', sceneGet(scene, 'height', 'mm'), sceneGet(scene, 'width', 'mm'));
    else, str = sprintf('Hgt,Wdth\t(%3.2f, %3.2f) um\n', sceneGet(scene, 'height', 'um'), sceneGet(scene, 'width', 'um'));
    end
    txt = addText(txt, str);

    u = round(log10(sceneGet(scene, 'sampleSize', 'm')));
    if (u >= 0), str = sprintf('Sample:\t%3.2f  m \n', sceneGet(scene, 'sampleSize', 'm'));
    elseif (u >= -3), str = sprintf('Sample:\t%3.2f mm \n', sceneGet(scene, 'sampleSize', 'mm'));
    else, str = sprintf('Sample:\t%3.2f um \n', sceneGet(scene, 'sampleSize', 'um'));
    end
    txt = addText(txt, str);

    str = sprintf('Deg/samp: %2.2f\n', sceneGet(scene, 'fov')/c);
    txt = addText(txt, str);

    wave = sceneGet(scene, 'wave');
    spacing = sceneGet(scene, 'binwidth');
    str = sprintf('Wave:\t%.0f:%.0f:%.0f nm\n', min(wave(:)), spacing, max(wave(:)));
    txt = addText(txt, str);

    luminance = sceneGet(scene, 'luminance');
    mx = max(luminance(:));
    mn = min(luminance(:));
    if mn == 0
        str = sprintf('DR: Inf\n  (max %.0f, min %.2f cd/m2)\n', mx, mn);
    else
        dr = mx / mn;
        str = sprintf('DR: %.2f dB (max %.0f cd/m2)\n', 20*log10(dr), mx);
    end
    txt = addText(txt, str);

    % Add the depth map range
    if isfield(scene, 'depthMap')
        dm = sceneGet(scene, 'depth map');
        str = sprintf('Depth range: [%.1f %.1f]m\n', min(dm(:)), max(dm(:)));
        txt = addText(txt, str);
    end

end

end