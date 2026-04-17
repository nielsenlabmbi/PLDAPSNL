function amountTime=rewardVol2Time(p,amountVol,chan)

%convert a reward amount specified in mL into the opening time for the
%reward delivery channel
%this uses the calibration numbers in the default parameters file 

slopeCh=p.trial.behavior.reward.volCoeff(chan);
offCh=p.trial.behavior.reward.volOffset(chan);

amountTime=(amountVol-offCh)/slopeCh;


