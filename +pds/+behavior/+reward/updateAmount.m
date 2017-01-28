function p = updateAmount(p,sel)
%update amount of a particular reward channel

switch sel
    case 1 %decrement first channel
        p.trial.behavior.reward.amount(1)=p.trial.behavior.reward.amount(1)-p.trial.behavior.reward.amountDelta;
    case 2 %increment first
        p.trial.behavior.reward.amount(1)=p.trial.behavior.reward.amount(1)+p.trial.behavior.reward.amountDelta;
    case 3 %decrement second 
        p.trial.behavior.reward.amount(2)=p.trial.behavior.reward.amount(2)-p.trial.behavior.reward.amountDelta;
    case 4 %increment second
        p.trial.behavior.reward.amount(2)=p.trial.behavior.reward.amount(2)+p.trial.behavior.reward.amountDelta;
    case 5 %decrement third
        p.trial.behavior.reward.amount(3)=p.trial.behavior.reward.amount(3)-p.trial.behavior.reward.amountDelta;
    case 6 %increment third
        p.trial.behavior.reward.amount(3)=p.trial.behavior.reward.amount(3)+p.trial.behavior.reward.amountDelta;
    case 7 %decrement fourth
        p.trial.behavior.reward.amount(4)=p.trial.behavior.reward.amount(4)-p.trial.behavior.reward.amountDelta;
    case 8 %increment fourth
        p.trial.behavior.reward.amount(4)=p.trial.behavior.reward.amount(4)+p.trial.behavior.reward.amountDelta;
end

disp('Updated reward amount')