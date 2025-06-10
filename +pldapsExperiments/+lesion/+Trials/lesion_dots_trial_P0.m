function lesion_dots_trial_P0(p,state)
%box acclimatization code

pldapsDefaultTrialFunction(p,state);

%add functions to particular states
switch state
    case p.trial.pldaps.trialStates.trialSetup
        trialSetup(p);
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        %check port status and set states accordingly
        checkState(p);
        
    case p.trial.pldaps.trialStates.frameDraw
        if p.trial.state==p.trial.stimulus.states.STIMON
            Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.iniColor,p.trial.stimulus.iniSize);
        end

    case p.trial.pldaps.trialStates.trialCleanUpandSave
        cleanUpandSave(p);
        
end


 

%-------------------------------------------------------------------%
%check port status and set events accordingly
function p=checkState(p)

activePort=find(p.trial.ports.status==1);

switch p.trial.state
    case p.trial.stimulus.states.START
        if p.trial.led.state==0
            %turn LED on
            pds.LED.LEDOn(p);
            p.trial.led.state=1;
            %note timepoint
            p.trial.stimulus.timeTrialLedOn = p.trial.ttime;
            p.trial.stimulus.frameTrialLedOn = p.trial.iFrame;
        end
         if activePort==p.trial.stimulus.port.START %start port activated
            
            %note timepoint
            p.trial.stimulus.timeTrialStartResp = p.trial.ttime;
            p.trial.stimulus.frameTrialStartResp = p.trial.iFrame;
            
            %turn LED off
            if p.trial.led.state==1
                pds.LED.LEDOff(p);
                p.trial.led.state=0;
            end
            
            %deliver reward
            amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.START);
            pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.START);
            
            %advance state
            p.trial.state=p.trial.stimulus.states.STIMON;
         end
         
    case p.trial.stimulus.states.STIMON %trial started
        if ismember(activePort, [p.trial.stimulus.port.LEFT p.trial.stimulus.port.RIGHT]) %port activated

            %play tone
            pds.audio.playDatapixxAudio(p,'reward_short');

            %give reward
            if activePort==p.trial.stimulus.port.LEFT
                amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
                pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
            elseif activePort==p.trial.stimulus.port.RIGHT
                amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
            end

            %advance state
            p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
            p.trial.state=p.trial.stimulus.states.FINALRESP;
        end
        
   
    case p.trial.stimulus.states.FINALRESP
        %wait for ITI
        if p.trial.ttime > p.trial.stimulus.timeTrialFinalResp + p.trial.stimulus.duration.ITI
            %trial done
            p.trial.state=p.trial.stimulus.states.TRIALCOMPLETE;
            p.trial.flagNextTrial = true;
        end
        
end

        
%------------------------------------------------------------------%
%setup trial parameters, prep stimulus as far as possible
function p=trialSetup(p)

%set up initialization stimulus (this could be in settings file)
p.trial.stimulus.iniColor=1;
p.trial.stimulus.iniSize=[500 200 1420 880];

%set state
p.trial.state=p.trial.stimulus.states.START;



function cleanUpandSave(p)

disp('----------------------------------')
disp(['Trialno: ' num2str(p.trial.pldaps.iTrial)])
%show reward amount
if p.trial.pldaps.draw.reward.show
    pds.behavior.reward.showReward(p,{'S';'L';'R'})
end
