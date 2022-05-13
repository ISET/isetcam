% Illustrate script for comparing spectral power distributions
%

wave = 400:10:700;
s1 = daylight(wave,4000);

% ieNewGraphWin; plot(wave,s1,'-',wave,s2,'--');

% Just the angle
ctemp = (4000:500:7000);

angval   = zeros(size(ctemp));
deval    = zeros(size(ctemp));
miredval = zeros(size(ctemp));

for ii=1:numel(ctemp)
    s2 = daylight(wave,ctemp(ii));
    angval(ii)   = metricsSPD(s1,s2,'metric','angle');
    deval(ii)    = metricsSPD(s1,s2,'metric','cielab','wave',wave);
    miredval(ii) = metricsSPD(s1,s2,'metric','mired','wave',wave);
end

ieNewGraphWin([],'tall');
subplot(2,1,1), plot(angval,deval,'-o')
xlabel('Angle'); ylabel('\Delta E');
identityLine;
grid on;

subplot(2,1,2), plot(angval,miredval,'-o')
xlabel('Angle'); ylabel('Mired');
identityLine;
grid on;

%% Now fix the white point at d65

for ii=1:numel(ctemp)
    s2 = daylight(wave,ctemp(ii));
    angval(ii)   = metricsSPD(s1,s2,'metric','angle');
    deval(ii)    = metricsSPD(s1,s2,'metric','cielab','wave',wave,'white point',[94.9409  100.0000  108.6656]);
    miredval(ii) = metricsSPD(s1,s2,'metric','mired','wave',wave);
end

ieNewGraphWin([],'tall');
subplot(2,1,1), plot(angval,deval,'-o')
xlabel('Angle'); ylabel('\Delta E');
identityLine;
grid on;

subplot(2,1,2), plot(angval,miredval,'-o')
xlabel('Angle'); ylabel('Mired');
identityLine;
grid on;

