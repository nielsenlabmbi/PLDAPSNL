function p = updateAmountVol(p,sel)
%update amount of a particular reward channel

switch sel
    case 1 %decrement first channel
        p.trial.behavior.reward.amountVol(1)=p.trial.behavior.reward.amountVol(1)-p.trial.behavior.reward.amountDeltaVol;
    case 2 %increment first
        p.trial.behavior.reward.amountVol(1)=p.trial.behavior.reward.amountVol(1)+p.trial.behavior.reward.amountDeltaVol;
    case 3 %decrement second 
        p.trial.behavior.reward.amountVol(2)=p.trial.behavior.reward.amountVol(2)-p.trial.behavior.reward.amountDeltaVol;
    case 4 %increment second
        p.trial.behavior.reward.amountVol(2)=p.trial.behavior.reward.amountVol(2)+p.trial.behavior.reward.amountDeltaVol;
    case 5 %decrement third
        p.trial.behavior.reward.amountVol(3)=p.trial.behavior.reward.amountVol(3)-p.trial.behavior.reward.amountDeltaVol;
    case 6 %increment third
        p.trial.behavior.reward.amountVol(3)=p.trial.behavior.reward.amountVol(3)+p.trial.behavior.reward.amountDeltaVol;

end

disp('***Updated reward amount')