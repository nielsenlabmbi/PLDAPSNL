function box_acclimation_free(p,state)
%%%% Note: includes staircase functionality for spatial frequency. Set
%%%% stimulus.step = 0 in settings file to suppress staircase. 

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
%         if p.trial.state==p.trial.stimulus.states.START
            Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.iniColor,p.trial.stimulus.iniSize);
%         elseif p.trial.state==p.trial.stimulus.states.STIMON || p.trial.state==p.trial.stimulus.states.INCORRECT
%             Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.stimColor,p.trial.stimulus.stimSize);
%         end
     
     
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        cleanUpandSave(p);
        
end


 

%-------------------------------------------------------------------%
%check port status and set events accordingly
function p=checkState(p)

activePort=find(p.trial.ports.status==1);

switch p.trial.state
    case p.trial.stimulus.states.START %trial started
         if ismember(activePort, [p.trial.stimulus.port.LEFT ...
                 p.trial.stimulus.port.RIGHT p.trial.stimulus.port.START])   
            %deliver reward
            %play tone
                pds.audio.playDatapixxAudio(p,'reward_short');
                
                %give reward
                if activePort==p.trial.stimulus.port.LEFT
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                elseif activePort==p.trial.stimulus.port.RIGHT
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
                else
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.START);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.START);
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
p.trial.stimulus.iniColor=0.5;
p.trial.stimulus.iniSize=[910 490 1010 590];

%set state
p.trial.state=p.trial.stimulus.states.START;

%display stats at end of trial
function cleanUpandSave(p)


disp('----------------------------------')
disp(['Trialno: ' num2str(p.trial.pldaps.iTrial)])
%show reward amount
if p.trial.pldaps.draw.reward.show
    pds.behavior.reward.showReward(p,{'S';'L';'R'})
end
