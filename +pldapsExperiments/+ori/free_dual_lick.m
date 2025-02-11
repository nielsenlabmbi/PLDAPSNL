function free_dual_lick(p,state)

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
%         if p.trial.state==p.trial.stimulus.states.RIGHT
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
        
        if p.trial.led.state==0
            %turn LED on
            pds.LED.LEDOn(p);
            p.trial.led.state=1;
            %note timepoint
            p.trial.stimulus.timeTrialLedOn = p.trial.ttime;
            p.trial.stimulus.frameTrialLedOn = p.trial.iFrame;
        end

        if p.trial.ttime > p.trial.stimulus.baseline && p.trial.ports.position(p.trial.stimulus.side.RIGHT)==0
             pds.ports.movePort(p.trial.stimulus.side.RIGHT,1,p);
             pds.ports.movePort(p.trial.stimulus.side.LEFT,1,p);
        end
        
        
        if activePort==p.trial.stimulus.port.RIGHT | activePort==p.trial.stimulus.port.LEFT %start port activated
            
            %turn LED off
            if p.trial.led.state==1
                pds.LED.LEDOff(p);
                p.trial.led.state=0;
            end

            %note timepoint
            p.trial.stimulus.timeTrialStartResp = p.trial.ttime;
            p.trial.stimulus.frameTrialStartResp = p.trial.iFrame;
            
            %deliver reward
            if activePort==p.trial.stimulus.port.RIGHT
                amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
            else
                amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
                pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
            end

            %advance state
            p.trial.state = p.trial.stimulus.states.LICKDELAY;
            
        end
        
    case p.trial.stimulus.states.LICKDELAY


            amountR=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
            amountL=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
            if p.trial.ttime < p.trial.stimulus.timeTrialStartResp + p.trial.stimulus.lickdelay & activePort==p.trial.stimulus.port.RIGHT %start port activated

                %deliver reward
                amountR=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                pds.behavior.reward.give(p,amountR,p.trial.behavior.reward.channel.RIGHT);
            end

            if p.trial.ttime < p.trial.stimulus.timeTrialStartResp + p.trial.stimulus.lickdelay & activePort==p.trial.stimulus.port.LEFT %start port activated

                %deliver reward
                amountL=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
                pds.behavior.reward.give(p,amountL,p.trial.behavior.reward.channel.LEFT);
            end

        
        if p.trial.ttime > p.trial.stimulus.timeTrialStartResp + max(amountR,amountL) + p.trial.stimulus.lickdelay;

            if p.trial.ports.position(p.trial.stimulus.side.RIGHT)==1
                pds.ports.movePort(p.trial.stimulus.side.RIGHT,0,p);
            end
            if p.trial.ports.position(p.trial.stimulus.side.LEFT)==1
                pds.ports.movePort(p.trial.stimulus.side.LEFT,0,p);
            end
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
p.trial.stimulus.iniSize=[910 490 1010 590];

%set state
p.trial.state=p.trial.stimulus.states.START;

%set ports correctly
pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.MIDDLE p.trial.stimulus.side.RIGHT],0,p);





%------------------------------------------------------------------%
%display stats at end of trial
function cleanUpandSave(p)


disp('----------------------------------')
disp(['Trialno: ' num2str(p.trial.pldaps.iTrial)])
%show reward amount
if p.trial.pldaps.draw.reward.show
    pds.behavior.reward.showReward(p,{'S';'L';'R'})
end


%show stats
if isfield(p.trial.stimulus,'timeTrialStartResp');
disp(['Time to lick:' num2str(p.trial.stimulus.timeTrialStartResp)]);
end

% pds.behavior.countTrial(p,p.trial.pldaps.goodtrial);
% disp(['C: ' num2str(p.trialMem.stats.val)])
% disp(['N: ' num2str(p.trialMem.stats.count.Ntrial)])
% disp(['P: ' num2str(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100)])
% 
% %if trial was locked, keep showing this trial
% if p.trialMem.lock==1
%     disp('Trial locked!')
%     thisCondition=p.conditions{p.trial.pldaps.iTrial}; 
%     p.conditions=[p.conditions(1:p.trial.pldaps.iTrial) thisCondition p.conditions(p.trial.pldaps.iTrial+1:end)];    
% end    

%%%%%%Helper functions
%-------------------------------------------------------------------%

   