function sensor = sensorGainOffset(sensor,ag,ao)
% Apply gain and offset to sensor volt iamge
%
% Synopsis
%
% Brief
%
% We check for an analog gain and offset.  For many years there was
% no analog gain parameter. This was added in January, 2008 when
% simulating some real devices. The manufacturers were clamping at
% zero and using the analog gain like wild men, rather than
% exposure duration. If these parameters are not set, they default
% to 1 (gain) and 0 (offset).
%
% Also, some people use gain as a multipler and some as a divider.
% Sorry for that.  Here you can see the formula.  We divide by the
% gain.
if ag ~=1 || ao ~= 0
    volts = sensorGet(sensor,'volts');

    % Some people prefer a gain and offset formula like this:
    %
    %    volts/ag + ao
    %
    % If you are one of those people, then when you set the ISETCam
    % analog offset level parameter think of the formula as
    %
    %   volts/ag + ao = volts/ag + (ao'/ag)
    %
    % where ao' is the ISETCam analog offset. Your analog offset
    % (ao) should be equal to the ISETCam analog offset (ao')
    % divided by the gain (ao'/ag).  Thus, the ISETCam analog
    % offset should be ao' = ao*ag.
    %
    volts = (volts + ao)/ag;
    sensor = sensorSet(sensor,'volts',volts);

    % Save the ag and ao.  If we aren't in this section, we
    % can just leave them as 1 and 0.
    sensor = sensorSet(sensor,'analog gain',ag);
    sensor = sensorSet(sensor,'analog offset',ao);
else
    % Do nothing.
    return;
end


end
