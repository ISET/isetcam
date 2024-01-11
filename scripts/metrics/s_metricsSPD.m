% Illustrate metrics to compare spectral power distributions using
% different measures.  
% 
% The vector angle, mired, and cielab $\Delta E$ measures.
%
% Surprisingly, the angle and $\Delta E$ are quite simply related.
%
% See also
%   v_metrics

wave = 400:10:700;

% Standard
s1 = daylight(wave,4000);

% ieNewGraphWin; plot(wave,s1,'-',wave,s2,'--');

% Select a range of color temperatures
ctemp = (4000:500:7000);

% Find the angle difference between the standard (daylight, 4000) and
% each of the other color temperatures
angval   = zeros(size(ctemp));
deval    = zeros(size(ctemp));
miredval = zeros(size(ctemp));

for ii=1:numel(ctemp)
    s2 = daylight(wave,ctemp(ii));
    angval(ii)   = metricsSPD(s1,s2,'metric','angle');
    deval(ii)    = metricsSPD(s1,s2,'metric','cielab','wave',wave);
    miredval(ii) = metricsSPD(s1,s2,'metric','mired','wave',wave);
end

%% Plot the relationships

ieNewGraphWin([],'tall');
tiledlayout(2,1);
nexttile; plot(angval,deval,'-o');
xlabel('Vector angle'); ylabel('\Delta E');
identityLine;
grid on; title('Standard D4000')

nexttile, plot(angval,miredval,'-o');
xlabel('Angle'); ylabel('Mired');
identityLine;
grid on;

%%
assert(abs(miredval(end) - 114.3814) < 1e-4);
assert(abs(angval(end) - 25.0450) < 1e-4);

%% Now fix the white point at d65

% Standard
s1 = daylight(wave,6500);

for ii=1:numel(ctemp)
    s2 = daylight(wave,ctemp(ii));
    angval(ii)   = metricsSPD(s1,s2,'metric','angle');
    deval(ii)    = metricsSPD(s1,s2,'metric','cielab','wave',wave,'white point',[94.9409  100.0000  108.6656]);
    miredval(ii) = metricsSPD(s1,s2,'metric','mired','wave',wave);
end

ieNewGraphWin([],'tall');
tiledlayout(2,1);
nexttile, plot(angval,deval,'-o');
xlabel('Angle'); ylabel('\Delta E');
identityLine;
grid on; title('Standard D6500')

nexttile, plot(angval,miredval,'-o');
xlabel('Angle'); ylabel('Mired');
identityLine;
grid on;

%%
assert(abs(miredval(end) - 12.0726) < 1e-4);
assert(abs(angval(end) - 2.6800) < 1e-4);

%% END
