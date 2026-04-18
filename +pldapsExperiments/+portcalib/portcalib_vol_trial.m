function portcalib_vol_trial(p,state)
%box acclimatization code

pldapsDefaultTrialFunction(p,state);

%add functions to particular states
switch state
    case p.trial.pldaps.trialStates.trialSetup
        trialSetup(p);
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
        %check port status and set states accordingly
        checkState(p);
        
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
        if ismember(activePort, [p.trial.stimulus.port.LEFT,p.trial.stimulus.port.RIGHT,p.trial.stimulus.port.START]) %any port selected
            
            %note timepoint
            p.trial.stimulus.timeTrialStartResp = p.trial.ttime;
            p.trial.stimulus.frameTrialStartResp = p.trial.iFrame;
            
            %turn LED off
            if p.trial.led.state==1
                pds.LED.LEDOff(p);
                p.trial.led.state=0;
            end
            
            %give reward
            if activePort==p.trial.stimulus.port.LEFT
                amountVol=p.trial.behavior.reward.amountVol(p.trial.stimulus.rewardIdx.LEFT);
                amount=pds.behavior.reward.rewardVol2Time(p,amountVol,p.trial.behavior.reward.channel.LEFT);
                pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
            elseif activePort==p.trial.stimulus.port.RIGHT
                amountVol=p.trial.behavior.reward.amountVol(p.trial.stimulus.rewardIdx.RIGHT);
                amount=pds.behavior.reward.rewardVol2Time(p,amountVol,p.trial.behavior.reward.channel.RIGHT);
                pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
              elseif activePort==p.trial.stimulus.port.START
                amountVol=p.trial.behavior.reward.amountVol(p.trial.stimulus.rewardIdx.START);
                amount=pds.behavior.reward.rewardVol2Time(p,amountVol,p.trial.behavior.reward.channel.START);
                pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.START);
            end

            p.trialMem.portCount(activePort)=p.trialMem.portCount(activePort)+1;
            
            %advance state
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

if ~isfield(p.trialMem,'portCount')
    p.trialMem.portCount = [0 0 0];
end

%set state
p.trial.state=p.trial.stimulus.states.START;



function cleanUpandSave(p)

disp('----------------------------------')
disp(['Trialno: ' num2str(p.trial.pldaps.iTrial)])
%show reward amount
if p.trial.pldaps.draw.reward.show
    pds.behavior.reward.showReward(p,{'S';'L';'R'})
end
disp('Port activations')
disp(p.trialMem.portCount)
