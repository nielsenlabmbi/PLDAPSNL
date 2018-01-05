%LED_trial
function LED_trial(p,state)
%use normal functionality in states
pldapsDefaultTrialFunction(p,state);

%add functions to particular states
switch state
    case p.trial.pldaps.trialStates.trialSetup
        trialSetup(p);
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        %check port status and set states accordingly
        checkState(p);
        
    case p.trial.pldaps.trialStates.frameDraw
            %Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.iniColor,p.trial.stimulus.iniSize);
     
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        cleanUpandSave(p);
        
end

function p=checkState(p)

activePort=find(p.trial.ports.status==1);

switch p.trial.state
    case p.trial.stimulus.states.START %trial started
        p.trial.led.channel = p.trial.led.channelStart;

        %flash LED
        for i = 1:5;
            pds.LED.LEDOn(p);
            WaitSecs(0.05);
            pds.LED.LEDOff(p);
            WaitSecs(0.05);
        end
        
        
        %dispense small reward
        amount=5*p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.START);
        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.START);
        
        %update state
        p.trial.stimulus.timeTrialWait = p.trial.ttime;
        p.trial.state = p.trial.stimulus.states.WAIT;
        
    case p.trial.stimulus.states.WAIT
        if p.trial.ttime > p.trial.stimulus.timeTrialWait + p.trial.stimulus.waitTime;
            p.trial.stimulus.timeTrialLedOn = p.trial.ttime;
            p.trial.state=p.trial.stimulus.states.STIMON;
        end
        
    case p.trial.stimulus.states.STIMON
        p.trial.led.channel = p.trial.led.channelTrial;

        %flash LED
        for i = 1:p.trial.stimulus.numflash;
            pds.LED.LEDOn(p);
            if p.trial.userInput==1 || p.trial.userInput==2
                disp('Saccade detected, reward dispensed')
                
                %note timepoint
                p.trial.stimulus.timeResp = p.trial.ttime;
                
                %dispense small reward
                amount=5*p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.START);
                pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.START);
                
                %mark as good trial
                p.trial.pldaps.goodtrial = 1;
                
                %update state
                p.trial.state = p.trial.stimulus.states.LICKDELAY;
                pds.LED.LEDOff(p);
                break
            end
            WaitSecs(p.trial.stimulus.pwd);
            pds.LED.LEDOff(p);
            WaitSecs(p.trial.stimulus.pwd);
        end
        
        if p.trial.userInput==1 || p.trial.userInput==2
            disp('Saccade detected, reward dispensed')
            
            %note timepoint
            p.trial.stimulus.timeResp = p.trial.ttime;
            
            %dispense small reward
            amount=5*p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.START);
            pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.START);
            
            %mark as good trial
            p.trial.pldaps.goodtrial = 1;
            
            %update state
            p.trial.state = p.trial.stimulus.states.LICKDELAY;
        end
        
           if p.trial.ttime > p.trial.stimulus.timeTrialLedOn + p.trial.stimulus.trialdur;
           p.trial.state = p.trial.stimulus.states.FINALRESP;
           end
       
    
    case p.trial.stimulus.states.LICKDELAY
        if p.trial.ttime < p.trial.stimulus.timeResp + p.trial.stimulus.lickdelay & activePort==p.trial.stimulus.port.START %start port activated
            %deliver reward
            amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.START);
            pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.START);
        end
        
        if p.trial.ttime > p.trial.stimulus.timeResp + p.trial.stimulus.lickdelay;
            p.trial.state=p.trial.stimulus.states.FINALRESP;
        end
        
    case p.trial.stimulus.states.FINALRESP
        %wait for ITI
        if p.trial.ttime > p.trial.stimulus.timeTrialLedOn + p.trial.stimulus.duration.ITI
            %trial done
            p.trial.state=p.trial.stimulus.states.TRIALCOMPLETE;
            p.trial.flagNextTrial = true;
        end
        
end


function p=trialSetup(p)

%set up initialization stimulus (this could be in settings file)
p.trial.stimulus.iniColor=1;
p.trial.stimulus.iniSize=[910 490 1010 590];

%set state
p.trial.state=p.trial.stimulus.states.START;

%set ports correctly
pds.ports.movePort([p.trial.ports.dio.channel.LEFT p.trial.ports.dio.channel.RIGHT p.trial.ports.dio.channel.MIDDLE],0,p);
if p.trial.ports.position(p.trial.ports.dio.channel.MIDDLE)==0
    pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,1,p);
    
%initialize LEDs
p.trial.led.channelStart = p.trial.stimulus.LEDChSt;
p.trial.led.channelTrial = p.conditions{p.trial.pldaps.iTrial}.LED;

end

%display stats at end of trial
function cleanUpandSave(p)


disp('----------------------------------')
disp(['Trialno: ' num2str(p.trial.pldaps.iTrial)])
% %show reward amount
if p.trial.pldaps.draw.reward.show
    pds.behavior.reward.showReward(p,{'S';'L';'R'})
end

%show stats
if isfield(p.trial.stimulus,'timeResp');
disp(['Est. time to saccade:' num2str(p.trial.stimulus.timeResp - p.trial.stimulus.timeTrialLedOn)]);
end