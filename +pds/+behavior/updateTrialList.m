
function p = updateTrialList(p)

%switch to new condition list
p.trialMem.whichConditions = mod(p.trialMem.whichConditions+1,length(p.trial.allconditions));
p.conditions = p.trial.allconditions{p.trialMem.whichConditions + 1};


disp(['Switched to trials list:' num2str(p.trialMem.whichConditions+1) ]);

