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


if p.trial.newEraSyringePump.use(logical(p.trial.ports.status))    
    pds.newEraSyringePump.give(p,amount);
elseif p.trial.datapixx.use
    if  p.trial.datapixx.useForReward
        if p.trial.datapixx.adc.useForReward
           pds.datapixx.analogOutTime(amount, chan, p.trial.behavior.reward.dacAmp,p.trial.datapixx.dac.sampleRate);
        end
        if p.trial.datapixx.dio.useForReward
            digital_out(chan,1);
            pause(amount);
            digital_out(chan,0);
            
%             wordvec=zeros(1,24);
%             wordvec(chan)=1;
%             word=bi2de(wordvec);
            
%             maskvec=zeros(1,24);
%             maskvec(chan)=1;
%             mask=bi2de(maskvec);
%             
%             %set digital channels, get duration
%             %t = p.trial.ttime + amount;
%             Datapixx('SetDoutValues', word,mask);
%             Datapixx('RegWrRd');
%             %wait pulse duration, close
%             pause(amount);
%             %if p.trial.ttime > t
%             wordvec(chan) = 0;
%             word=bi2de(wordvec);
%             Datapixx('SetDoutValues', word,mask);
%             Datapixx('RegWrRd');
%             %end
            
        end
    end
    %%flag
    pds.datapixx.flipBit(p,p.trial.event.REWARD,p.trial.pldaps.iTrial);
end

% if p.trial.datapixx.use
%     if  p.trial.datapixx.useForReward
%         pds.datapixx.analogOutTime(amount, chan, p.trial.behavior.reward.dacAmp,p.trial.datapixx.dac.sampleRate);
%     end
%     %%flag
%     pds.datapixx.flipBit(p,p.trial.event.REWARD,p.trial.pldaps.iTrial);
% end

%%sound
%if p.trial.sound.use
%    PsychPortAudio('Start', p.trial.sound.reward);
%end

% store data
p.trial.behavior.reward.timeReward(:,p.trial.behavior.reward.iReward) = [GetSecs amount];
p.trial.behavior.reward.chReward(p.trial.behavior.reward.iReward) = chan;
p.trial.behavior.reward.iReward = p.trial.behavior.reward.iReward + 1;
