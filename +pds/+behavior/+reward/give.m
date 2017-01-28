function p = give(p, amount, chan)
%pds.behavior.reward.give(p, amount)    give a certaim amount of reward
% handles reward for newEraSyringePumps and via TTL over datapixx. Also
% send a reward bit via datapixx (if datapixx is used).
% stores the time and amount in p.trial.behavior.reward.timeReward
% If no amount is specified, the value set in
% p.trial.behavior.reward.defaultAmount will be used

if nargin < 3
    chan = 3; %just for consistency with the analogOut function
end

if nargin < 2
    amount = p.trial.behavior.reward.defaultAmount;
end


if p.trial.newEraSyringePump.use    
    pds.newEraSyringePump.give(p,amount);
end

if p.trial.datapixx.use
    if  p.trial.datapixx.useForReward
        pds.datapixx.analogOut(amount, chan, p.trial.behavior.reward.dacAmp);
    end
    %%flag
    pds.datapixx.flipBit(p.trial.event.REWARD,p.trial.pldaps.iTrial);
end

%%sound
%if p.trial.sound.use
%    PsychPortAudio('Start', p.trial.sound.reward);
%end

% store data
p.trial.behavior.reward.timeReward(:,p.trial.behavior.reward.iReward) = [GetSecs amount];
p.trial.behavior.reward.chReward(p.trial.behavior.reward.iReward) = chan;
p.trial.behavior.reward.iReward = p.trial.behavior.reward.iReward + 1;
