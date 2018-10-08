function photoreceptors = StockmanSharpePhotoreceptors(wave)
% photoreceptors = StockmanSharpePhotoreceptors(wave)
%
% Returnt the PTB photoreceptors for standard Stockman-Sharpe (aka CIE)
% two-degree photoreceptors, on the passed wavelength sampling.
%
% In isetbio, the main purpose of this routine is to validate that the
% isetbio cone/lens/macular structures are consistent with the PTB.
%
% ISETBIO Team, 2014


%% Set up PTB photoreceptors structure

% We'll do the computations at the wavelength spacing passed in for the
% spectrum of interest.
whatCalc = 'CIE2Deg';
photoreceptors = DefaultPhotoreceptors(whatCalc);
photoreceptors.nomogram.S = WlsToS(wave(:));
S = photoreceptors.nomogram.S;
photoreceptors = FillInPhotoreceptors(photoreceptors);

end