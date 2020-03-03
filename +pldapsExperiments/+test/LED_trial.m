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
        
disp(num2str(p.trial.led.channelTrial));
        p.trial.led.channel = p.trial.led.channelStart;
        pds.LED.LEDOn(p);
        WaitSecs(0.3);
        pds.LED.LEDOff(p);
%                 amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.START);
%                 pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.START);
        WaitSecs(0.2);
        
        p.trial.stimulus.timeTrialWait = p.trial.ttime;
        p.trial.stimulus.timeTrialLedOn = p.trial.ttime;
        p.trial.led.channel = p.trial.led.channelTrial;
        pds.LED.LEDOn(p);
        if p.trial.ports.position(p.trial.stimulus.side.MIDDLE)==0
            pds.ports.movePort(p.trial.stimulus.side.MIDDLE,1,p);
        end
        p.trial.state = p.trial.stimulus.states.STIMON;
        
    case p.trial.stimulus.states.STIMON
            %pds.LED.LEDOn(p);
            
            if p.trial.userInput==1 || p.trial.userInput==2; %|| p.trial.led.channel == p.trial.led.channelStart;
                disp('Saccade detected, reward dispensed')
                pds.LED.LEDOff(p);
                
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
            if p.trial.ttime > p.trial.stimulus.timeTrialWait + p.trial.stimulus.pwd;
                pds.LED.LEDOff(p);
                p.trial.stimulus.timeTrialWait = p.trial.ttime;
                p.trial.state=p.trial.stimulus.states.WAIT;
            end
            
           if p.trial.ttime > p.trial.stimulus.timeTrialLedOn + p.trial.stimulus.trialdur;
           p.trial.state = p.trial.stimulus.states.FINALRESP;
           end
           
    case p.trial.stimulus.states.WAIT
        %pds.LED.LEDOff(p)
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
            
        end
        if p.trial.ttime > p.trial.stimulus.timeTrialWait + p.trial.stimulus.pwd;
            pds.LED.LEDOn(p);
            p.trial.stimulus.timeTrialWait = p.trial.ttime;
            p.trial.state=p.trial.stimulus.states.STIMON;
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
            pds.LED.LEDOff(p);
            p.trial.state=p.trial.stimulus.states.TRIALCOMPLETE;
            p.trial.flagNextTrial = true;
            pds.ports.movePort(p.trial.stimulus.side.MIDDLE,0,p); 
        end
        
end


function p=trialSetup(p)

%set up initialization stimulus (this could be in settings file)
p.trial.stimulus.iniColor=1;
p.trial.stimulus.iniSize=[910 490 1010 590];

%set state
p.trial.state=p.trial.stimulus.states.START;

%set ports correctly
pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT p.trial.stimulus.side.MIDDLE],0,p);

    
%initialize LEDs
p.trial.led.channelStart = p.conditions{p.trial.pldaps.iTrial}.LEDSt;
p.trial.led.channelTrial = p.conditions{p.trial.pldaps.iTrial}.LED;
p.trial.led.channel = p.trial.stimulus.LEDCh;
pds.LED.LEDOff(p)


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
