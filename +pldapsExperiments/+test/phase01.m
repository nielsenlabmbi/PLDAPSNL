function phase01(p,state)

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
%             Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.iniColor,p.trial.stimulus.iniSize);
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
           
    case p.trial.stimulus.states.STIMON
        
        if p.trial.ttime > p.trial.stimulus.stimON
            if p.trial.side == p.trial.stimulus.side.LEFT && p.trial.ports.position(p.trial.ports.dio.channel.LEFT)==0 
                pds.ports.movePort(p.trial.ports.dio.channel.LEFT,1,p);

            end
            
            if p.trial.side == p.trial.stimulus.side.RIGHT && p.trial.ports.position(p.trial.ports.dio.channel.RIGHT)==0;
                pds.ports.movePort(p.trial.ports.dio.channel.RIGHT,1,p);

            end
            
            if p.trial.side == p.trial.stimulus.side.MIDDLE && p.trial.ports.position(p.trial.ports.dio.channel.MIDDLE)==0;
                pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,1,p);

            end
            
            if any(p.trial.ports.status)
                
                %note timepoint
                p.trial.stimulus.timeResp = p.trial.ttime;
                p.trial.stimulus.frameResp = p.trial.iFrame;
                
               
                %advance state
                p.trial.state=p.trial.stimulus.states.LICKDELAY;
                
            end
                

        end
        
    case p.trial.stimulus.states.LICKDELAY %deliver reward
        
                if activePort==p.trial.stimulus.port.LEFT
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT)/p.trial.behavior.reward.pulseFreq;
                    for i = 1:p.trial.behavior.reward.pulseFreq
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                        WaitSecs(p.trial.behavior.reward.pulseInt);
                    end
                    WaitSecs(p.trial.behavior.reward.pulseInt*3);
%                     
                elseif activePort==p.trial.stimulus.port.RIGHT
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT)/p.trial.behavior.reward.pulseFreq;
                    for i = 1:p.trial.behavior.reward.pulseFreq;
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
                        WaitSecs(p.trial.behavior.reward.pulseInt);
                    end
                    WaitSecs(p.trial.behavior.reward.pulseInt*3);
                    
               elseif activePort==p.trial.stimulus.port.START
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.START)/p.trial.behavior.reward.pulseFreq;
                    for i = 1:p.trial.behavior.reward.pulseFreq;
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.START);
                        WaitSecs(p.trial.behavior.reward.pulseInt);
                    end
                    WaitSecs(p.trial.behavior.reward.pulseInt*3);
                end
                
                 %advance state
                if any(p.trial.ports.position)
                    pds.ports.movePort([p.trial.ports.dio.channel.LEFT p.trial.ports.dio.channel.RIGHT p.trial.ports.dio.channel.MIDDLE],0,p);
                end
                p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
                p.trial.state=p.trial.stimulus.states.FINALRESP;
                
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

%get side for condition
if p.conditions{p.trial.pldaps.iTrial}.side==1
    p.trial.side=p.trial.stimulus.side.LEFT;
elseif p.conditions{p.trial.pldaps.iTrial}.side==2
    p.trial.side=p.trial.stimulus.side.RIGHT;
else
    p.trial.side = p.trial.stimulus.side.MIDDLE;
end
if isfield(p.trialMem,'waitTime');
    p.trial.stimulus.waitTime = p.trialMem.waitTime;
end

%set up initialization stimulus (this could be in settings file)
p.trial.stimulus.iniColor=1;
p.trial.stimulus.iniSize=[910 490 1010 590];

%set up stimulus
p.trial.stimulus.stimColor=p.conditions{p.trial.pldaps.iTrial}.color;
p.trial.stimulus.stimSize=[400 400 800 800];

%set state
p.trial.state=p.trial.stimulus.states.STIMON;

%set ports correctly
pds.ports.movePort([p.trial.ports.dio.channel.LEFT p.trial.ports.dio.channel.RIGHT p.trial.ports.dio.channel.MIDDLE],0,p);
%determine which spouts are presented when stimulus is presented
p.trial.ports.moveBool = double(rand > p.trial.stimulus.fracInstruct);



%------------------------------------------------------------------%
%display stats at end of trial
function cleanUpandSave(p)
%+/- wait time
if p.trial.userInput==1
    p.trialMem.waitTime = p.trial.stimulus.waitTime - 0.25;
    disp('decreased waitTime')
end
if p.trial.userInput==2
    p.trialMem.waitTime = p.trial.stimulus.waitTime + 0.25;
    disp('increased waitTime')
end

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
%if trial was locked, keep showing this trial
if p.trialMem.lock==1
    disp('Trial locked!')
    thisCondition=p.conditions{p.trial.pldaps.iTrial};
    p.conditions=[p.conditions(1:p.trial.pldaps.iTrial) thisCondition p.conditions(p.trial.pldaps.iTrial+1:end)];
end

%%%%%%Helper functions
%-------------------------------------------------------------------%

