function port_acclimation(p,state)

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
%             Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.iniColor,p.trial.stimulus.iniSize);
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
        
        if p.trial.led.state==0
            %turn LED on
            pds.LED.LEDOn(p);
            p.trial.led.state=1;
            %note timepointc
            p.trial.stimulus.timeTrialLedOn = p.trial.ttime;
            p.trial.stimulus.frameTrialLedOn = p.trial.iFrame;
        end
        
            if mod(p.trial.ttime,10)<2 && p.trial.ports.position(p.trial.ports.dio.channel.MIDDLE)==0
                pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,1,p);
                pds.ports.movePort([p.trial.ports.dio.channel.LEFT p.trial.ports.dio.channel.RIGHT],0,p);
            end
            
            if mod(p.trial.ttime,10)>2 && mod(p.trial.ttime,10)<4 && p.trial.ports.position(p.trial.ports.dio.channel.MIDDLE)==1;
                pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,0,p);
                pds.ports.movePort([p.trial.ports.dio.channel.LEFT p.trial.ports.dio.channel.RIGHT],1,p);
            end
            
            if mod(p.trial.ttime,10) > 4 && mod(p.trial.ttime,10)< 6 && p.trial.ports.position(p.trial.ports.dio.channel.RIGHT)==1
                pds.ports.movePort(p.trial.ports.dio.channel.RIGHT,0,p);
%                 pds.ports.movePort(p.trial.ports.dio.channel.LEFT,1,p);
%                 pds.ports.movePort([p.trial.ports.dio.channel.RIGHT p.trial.ports.dio.channel.MIDDLE],0,p);
            end
            
            if mod(p.trial.ttime,10) > 6 && mod(p.trial.ttime,10)< 8 && p.trial.ports.position(p.trial.ports.dio.channel.LEFT) == 1
                pds.ports.movePort(p.trial.ports.dio.channel.LEFT,0,p);
                pds.ports.movePort(p.trial.ports.dio.channel.RIGHT,1,p);
%                 pds.ports.movePort([p.trial.ports.dio.channel.LEFT p.trial.ports.dio.channel.MIDDLE],0,p);
%                 pds.ports.movePort(p.trial.ports.dio.channel.RIGHT,1,p);
            end
            
            if mod(p.trial.ttime,10) > 8 && mod(p.trial.ttime,10) < 9.9 && p.trial.ports.position(p.trial.ports.dio.channel.RIGHT) ==1;
                pds.ports.movePort([p.trial.ports.dio.channel.LEFT p.trial.ports.dio.channel.RIGHT p.trial.ports.dio.channel.MIDDLE],0,p);
            end
%             
%             if p.trial.ttime > 20;
%             pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,1,p);
%             end
%             %move response ports (only if necessary)
%             if p.trial.ports.position(p.trial.ports.dio.channel.MIDDLE)==1
%                pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,0,p);
%                pds.ports.movePort([p.trial.ports.dio.channel.LEFT p.trial.ports.dio.channel.RIGHT],1,p);
%             end

        
    
        
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
else
    p.trial.side=p.trial.stimulus.side.RIGHT;
end

%set state
p.trial.state=p.trial.stimulus.states.START;

%set ports correctly
pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,1,p);
pds.ports.movePort([p.trial.ports.dio.channel.LEFT p.trial.ports.dio.channel.RIGHT],0,p);









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
pds.behavior.countTrial(p,p.trial.pldaps.goodtrial);
disp(['C: ' num2str(p.trialMem.stats.val)])
disp(['N: ' num2str(p.trialMem.stats.count.Ntrial)])
disp(['P: ' num2str(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100)])

%if trial was locked, keep showing this trial
if p.trialMem.lock==1
    disp('Trial locked!')
    thisCondition=p.conditions{p.trial.pldaps.iTrial}; 
    p.conditions=[p.conditions(1:p.trial.pldaps.iTrial) thisCondition p.conditions(p.trial.pldaps.iTrial+1:end)];    
end    

%%%%%%Helper functions
%-------------------------------------------------------------------%
%check whether a particular port choice is correct
function correct=checkPortChoice(activePort,p)

correct=0;

switch p.trial.side
    case p.trial.stimulus.side.LEFT
        if activePort==p.trial.stimulus.side.LEFT
            correct=1;
        end
    case p.trial.stimulus.side.RIGHT
        if activePort==p.trial.stimulus.side.RIGHT
            correct=1;
        end
    case p.trial.stimulus.side.MIDDLE
        if activePort==p.trial.stimulus.side.MIDDLE
            correct=1;
        end
end

   