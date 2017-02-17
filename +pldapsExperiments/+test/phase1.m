function phase1(p,state)

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
        if p.trial.state==p.trial.stimulus.states.START
            Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.iniColor,p.trial.stimulus.iniSize);
%         elseif p.trial.state==p.trial.stimulus.states.STIMON || p.trial.state==p.trial.stimulus.states.INCORRECT
%             Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.stimColor,p.trial.stimulus.stimSize);
        end
     
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        cleanUpandSave(p);
        
end


 

%-------------------------------------------------------------------%
%check port status and set events accordingly
function p=checkState(p)

activePort=find(p.trial.ports.status==1);


switch p.trial.state
    case p.trial.stimulus.states.START %trial started
        
%         if p.trial.led.state==0
%             %turn LED on
%             pds.LED.LEDOn(p);
%             p.trial.led.state=1;
%             %note timepoint
%             p.trial.stimulus.timeTrialLedOn = p.trial.ttime;
%             p.trial.stimulus.frameTrialLedOn = p.trial.iFrame;
%         end

        if p.trial.ttime > p.trial.stimulus.baseline && p.trial.ports.position(p.trial.ports.dio.channel.MIDDLE)==0
             pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,1,p);
        end
        
        
        if activePort==p.trial.stimulus.port.START %start port activated
            
            %turn LED off
            if p.trial.led.state==1
                pds.LED.LEDOff(p);
                p.trial.led.state=0;
            end

            %note timepoint
            p.trial.stimulus.timeTrialStartResp = p.trial.ttime;
            p.trial.stimulus.frameTrialStartResp = p.trial.iFrame;
            
            %advance state
            p.trial.state = p.trial.stimulus.states.LICKDELAY;
            
        end
        
    case p.trial.stimulus.states.LICKDELAY
        
            %deliver reward
            amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.START);
            pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.START);
            
         if p.trial.ttime > p.trial.stimulus.timeTrialStartResp + amount + p.trial.stimulus.lickdelay;
                if p.trial.ports.position(p.trial.ports.dio.channel.MIDDLE)==1
                    pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,0,p);
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
%  
% %get side for condition
% if p.conditions{p.trial.pldaps.iTrial}.side==1
%     p.trial.side=p.trial.stimulus.side.LEFT;
% else
%     p.trial.side=p.trial.stimulus.side.RIGHT;
% end

%set up initialization stimulus (this could be in settings file)
p.trial.stimulus.iniColor=1;
p.trial.stimulus.iniSize=[500 500 600 600];

%set state
p.trial.state=p.trial.stimulus.states.START;

%set ports correctly
pds.ports.movePort([p.trial.ports.dio.channel.LEFT p.trial.ports.dio.channel.RIGHT p.trial.ports.dio.channel.MIDDLE],0,p);




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

   