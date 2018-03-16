function p = cleanUpandSave(p)
%pds.behavior.reward.cleanUpandSave(p)    clean up after a trial
% Store any necessary data from the different reward modules. This is
% mostly a wrapper to the other modules. But also removes any unused fields
% of p.trial.behavior.reward.timeReward

if any(p.trial.newEraSyringePump.use) 
    pds.newEraSyringePump.cleanUpandSave(p);
end
    
%nothing to do for other reward modes

p.trial.behavior.reward.timeReward(isnan(p.trial.behavior.reward.timeReward))=[];
p.trial.behavior.reward.chReward(isnan(p.trial.behavior.reward.chReward))=[];