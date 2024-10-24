function somtrialhpGrey(p,state)

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
        Screen('FillRect',p.trial.display.ptr,[192 192 192]);
        %        if p.trial.state==p.trial.stimulus.states.START
        %             Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.iniColor,p.trial.stimulus.iniSize);
        %         elseif p.trial.state==p.trial.stimulus.states.STIMON || p.trial.state==p.trial.stimulus.states.INCORRECT
        %             showStimulus(p);
        %         elseif p.trial.state == p.trial.stimulus.states.WAIT
        %             Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.waitColor,p.trial.stimulus.iniSize);
        %        end
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        cleanUpandSave(p);
        
end




%-------------------------------------------------------------------%
%check port status and set events accordingly
function p=checkState(p)

import zaber.motion.Library;
import zaber.motion.ascii.Connection;
import zaber.motion.Units;
import zaber.motion.ascii.AxisSettings;
import zaber.motion.ascii.AllAxes;
import zaber.motion.ascii.Axis;
import zaber.motion.ascii.Stream;
import zaber.motion.Measurement;

Library.enableDeviceDbStore();

global zaber;

activePort=find(p.trial.ports.status==1);


switch p.trial.state
    case p.trial.stimulus.states.START %trial started
                
        if p.trial.ttime > p.trial.stimulus.baseline && p.trial.ports.position(p.trial.stimulus.side.MIDDLE)==0
            pds.ports.movePort(p.trial.stimulus.side.MIDDLE,1,p);
        end
        
        if activePort==p.trial.stimulus.port.START %start port activated
            %deliver reward
            amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.START);
            pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.START);
            
            %note timepoint
            p.trial.stimulus.timeTrialStartResp = p.trial.ttime;
            p.trial.stimulus.frameTrialStartResp = p.trial.iFrame;
            
            %advance state
            p.trial.state = p.trial.stimulus.states.LICKDELAY;
            p.trial.stimulus.switchVAR = 0;
        end
        
    case p.trial.stimulus.states.LICKDELAY
        switch p.trial.stimulus.switchVAR
            case 0 %start of trials
                
                if p.trial.ttime < p.trial.stimulus.timeTrialStartResp + 0.5 & activePort==p.trial.stimulus.port.START %start port activated
                    %deliver reward
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.START);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.START);
                end
                
                if p.trial.ttime > p.trial.stimulus.timeTrialStartResp + 0.5
                    if p.trial.ports.position(p.trial.stimulus.side.MIDDLE)==1
                        pds.ports.movePort(p.trial.stimulus.side.MIDDLE,0,p);
                    end
                    p.trial.stimulus.timeTrialWait = p.trial.ttime;
                    p.trial.stimulus.frameTrialWait = p.trial.iFrame;
                    p.trial.state=p.trial.stimulus.states.WAIT;
                end
                
            case 1 %correct trials
                p.trial.pldaps.licks = [];
                %give reward
                if p.trial.ttime < p.trial.stimulus.timeResp + p.trial.stimulus.lickdelayR & ...
                        activePort==p.trial.stimulus.port.RIGHT & activePort == p.trial.side %active port is the correct port
                    %deliver reward
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
                    %note timepoint
                    p.trial.pldaps.licks = [p.trial.pldaps.licks p.trial.ttime];
                end
                
                if p.trial.ttime < p.trial.stimulus.timeResp + p.trial.stimulus.lickdelayL & ...
                        activePort==p.trial.stimulus.port.LEFT & activePort == p.trial.side %active port is the correct port
                    %deliver reward
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                    %note timepoint
                    p.trial.pldaps.licks = [p.trial.pldaps.licks p.trial.ttime];
                    
                end
                
                if p.trial.ttime > p.trial.stimulus.timeResp + p.trial.stimulus.lickdelay
                    if any(p.trial.ports.position)
                        pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT],0,p);
                    end
                    p.trial.state=p.trial.stimulus.states.FINALRESP;
                end
                
            case 2 %incorrect trials
                
                if p.trial.ttime > p.trial.stimulus.timeResp + p.trial.stimulus.forceCorrect_delay
                    if any(p.trial.ports.position)
                        pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT],0,p);
                    end
                    p.trial.state=p.trial.stimulus.states.FINALRESP;
                end
                
        end
        
    case p.trial.stimulus.states.WAIT
        
        if p.trial.ttime > p.trial.stimulus.timeTrialWait + p.trial.stimulus.waitTime
            p.trial.stimulus.timeTrialStimOn = p.trial.ttime;
            p.trial.stimulus.frameTrialStimOn = p.trial.iFrame;
            p.trial.state=p.trial.stimulus.states.MOVESTAGE;
        end
      
    case  p.trial.stimulus.states.MOVESTAGE  
        
        %move stage to animal
        zaber.axis(p.trial.stimulus.orthaxis).moveAbsolute(p.trial.stimulus.orthoff(2),Units.LENGTH_MILLIMETRES);

        %rotate stage if selected
        if p.trial.stimulus.moveduring==1
            zaber.axis(p.trial.stimulus.rotaxis).moveAbsolute(p.trial.stimulus.rotoff,Units.ANGLE_DEGREES);
        end
        p.trial.state=p.trial.stimulus.states.STIMON;
        
    case p.trial.stimulus.states.STIMON %stimulus shown; port selected in response

        %wait to make ports available
        if p.trial.ttime > p.trial.stimulus.timeTrialStimOn + 3.0 + p.trial.stimulus.stimON && ...
                p.trial.ports.position(p.trial.stimulus.side.LEFT)==0 && p.trial.ports.position(p.trial.stimulus.side.RIGHT)==0
            pds.ports.movePort(p.trial.side,1,p); 
            pds.ports.movePort(1 + mod(p.trial.side,2),p.trial.ports.moveBool,p);
        end
        
        %check whether any port chosen
        if length(activePort) > 1 %if more than one port is activated
            
            %retract spouts
            pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT p.trial.stimulus.side.MIDDLE],0,p);
            %wait
            WaitSecs(4);
            %present spouts again
            pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT],1,p);
            
        elseif length(activePort) == 1 & activePort==p.trial.stimulus.port.LEFT | activePort==p.trial.stimulus.port.RIGHT & ...
                p.trial.ttime > p.trial.stimulus.timeTrialStimOn + p.trial.stimulus.stimON
            %note time
            p.trial.stimulus.timeTrialFirstResp = p.trial.ttime;
            p.trial.stimulus.frameTrialFirstResp = p.trial.iFrame;
            
            %note response
            %p.trial.stimulus.respTrial=activePort;
            p.trial.stimulus.respTrial=p.trial.ports.status;
            
            %check whether correct port chosen
            correct=checkPortChoice(activePort,p);
            if correct==1
                p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
                if  activePort==p.trial.stimulus.port.RIGHT & activePort == p.trial.side %active port is the correct port
                    %deliver reward
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
                end
                if  activePort==p.trial.stimulus.port.LEFT & activePort == p.trial.side %active port is the correct port
                    %deliver reward
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                end
                %play tone
                pds.audio.playDatapixxAudio(p,'reward_short');
                
                %retract incorrect spout
                if p.trial.side==p.trial.stimulus.side.LEFT
                    if p.trial.ports.position(p.trial.stimulus.side.RIGHT)==1
                        pds.ports.movePort(p.trial.stimulus.side.RIGHT,0,p);
                    end
                end
                if p.trial.side==p.trial.stimulus.side.RIGHT
                    if p.trial.ports.position(p.trial.stimulus.side.LEFT)==1
                        pds.ports.movePort(p.trial.stimulus.side.LEFT,0,p);
                    end
                end
                
                
                %advance state
                p.trial.stimulus.switchVAR = 1;
                p.trial.state=p.trial.stimulus.states.LICKDELAY;
                p.trial.stimulus.timeResp = p.trial.ttime;
                %note good trial
                p.trial.pldaps.goodtrial = 1;
                
            else
                %play tone
                pds.audio.playDatapixxAudio(p,'breakfix');
                p.trial.pldaps.goodtrial = 0;
                %advance state
                p.trial.state=p.trial.stimulus.states.INCORRECT;
            end
        end
        
        
    case p.trial.stimulus.states.INCORRECT %incorrect port selected for stimulus
        if p.trial.stimulus.forceCorrect == 1 %must give correct response before ending trial
            
            %retract incorrect spout
            if p.trial.side==p.trial.stimulus.side.LEFT
                if p.trial.ports.position(p.trial.stimulus.side.RIGHT)==1
                    pds.ports.movePort(p.trial.stimulus.side.RIGHT,0,p);
                end
            end
            if p.trial.side==p.trial.stimulus.side.RIGHT
                if p.trial.ports.position(p.trial.stimulus.side.LEFT)==1
                    pds.ports.movePort(p.trial.stimulus.side.LEFT,0,p);
                end
            end
            
            %check whether any port chosen
            if activePort==p.trial.stimulus.port.LEFT | activePort==p.trial.stimulus.port.RIGHT
                %check whether correct port chosen
                correct=checkPortChoice(activePort,p);
                if correct==1 %now has chosen correct port
                    p.trial.stimulus.timeResp = p.trial.ttime;
                    p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                    p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
                    
                    if p.trial.ttime < p.trial.stimulus.timeResp + p.trial.stimulus.forceCorrect_delay & activePort==p.trial.stimulus.port.RIGHT
                        %deliver reward
                        amount=0.06; %p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
                        
                    end
                    
                    if p.trial.ttime < p.trial.stimulus.timeResp + p.trial.stimulus.forceCorrect_delay & activePort==p.trial.stimulus.port.LEFT
                        %deliver reward
                        amount= 0.06;%p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                        
                    end
                    
                    %advance state
                    p.trial.stimulus.switchVAR = 2;
                    p.trial.state=p.trial.stimulus.states.LICKDELAY;
                    
                end
            end
            
        else %incorrect responses end trial immediately
            %retract spouts
            if any(p.trial.ports.position)
                pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT],0);
            end
            
            %wait for ITI
            if p.trial.ttime > p.trial.stimulus.timeTrialFirstResp + p.trial.stimulus.duration.ITI
                %trial done
                p.trial.state=p.trial.stimulus.states.TRIALCOMPLETE;
                p.trial.flagNextTrial = true;
            end
        end
        
    case p.trial.stimulus.states.FINALRESP
        
        %wait for ITI
        if p.trial.ttime > p.trial.stimulus.timeTrialFinalResp + p.trial.stimulus.duration.ITI + p.trial.stimulus.timeout*(~p.trial.pldaps.goodtrial)
            %trial done
            %move stage out of the way
            zaber.axis(p.trial.stimulus.orthaxis).moveAbsolute(p.trial.stimulus.orthoff(1),Units.LENGTH_MILLIMETRES);
            
            p.trial.state=p.trial.stimulus.states.TRIALCOMPLETE;
            p.trial.flagNextTrial = true;
        end
        
end




%------------------------------------------------------------------%
%setup trial parameters, prep stimulus as far as possible
function p=trialSetup(p)

import zaber.motion.Library;
import zaber.motion.ascii.Connection;
import zaber.motion.Units;
import zaber.motion.ascii.AxisSettings;
import zaber.motion.ascii.AllAxes;
import zaber.motion.ascii.Axis;
import zaber.motion.ascii.Stream;
import zaber.motion.Measurement;

Library.enableDeviceDbStore();


global zaber;

%get side for condition
if p.conditions{p.trial.pldaps.iTrial}.side==2
    p.trial.side=p.trial.stimulus.side.LEFT;
else
    p.trial.side=p.trial.stimulus.side.RIGHT;
end

%deal with fraction instructive trials if there were manual adjustments
if isfield(p.trialMem,'fracInstruct')
    p.trial.stimulus.fracInstruct = p.trialMem.fracInstruct;
end

%adjust fraction instructive trials (regulated by moveBool)
if ~isfield(p.trialMem,'count') || p.trialMem.count == 0
    p.trialMem.count = 1;
    p.trialMem.moveBool = zeros(1,10);
    p.trialMem.moveBool(1:round((1 - p.trial.stimulus.fracInstruct)*10)) = 1;
    p.trialMem.moveBool = p.trialMem.moveBool(randperm(10));
end

p.trial.ports.moveBool = p.trialMem.moveBool(p.trialMem.count);
p.trialMem.count = mod(p.trialMem.count+1,11);

%lick delay
if length(p.trial.stimulus.lickdelay) > 1
    p.trial.stimulus.lickdelayL = p.trial.stimulus.lickdelay(1);
    p.trial.stimulus.lickdelayR = p.trial.stimulus.lickdelay(2);
else
    p.trial.stimulus.lickdelayL = p.trial.stimulus.lickdelay;
    p.trial.stimulus.lickdelayR = p.trial.stimulus.lickdelay;
end


% set up stimulus
%determine shape and stage position
if p.conditions{p.trial.pldaps.iTrial}.curvetype==1
    p.trial.stimulus.shapenr=p.conditions{p.trial.pldaps.iTrial}.shapeid; %results either 1 or 2
else
    p.trial.stimulus.shapenr=p.conditions{p.trial.pldaps.iTrial}.shapeid+2; %results either 3 or 4
end

p.trial.stimulus.rotangle=p.trial.stimulus.angle(p.trial.stimulus.shapenr)+rand(1)*p.trial.stimulus.rotrange;

orand=rand(1);
o1=max(p.trial.stimulus.orthpos(1)+orand*p.trial.stimulus.orthrange,0); 
o2=min(p.trial.stimulus.orthpos(2)+orand*p.trial.stimulus.orthrange,50); 

p.trial.stimulus.orthoff=[o1 o2]; %we're adjusting both start and stop position
p.trial.stimulus.paroff=p.trial.stimulus.parpos+rand(1)*p.trial.stimulus.parrange;
p.trial.stimulus.rotoff=p.trial.stimulus.rotangle+p.trial.stimulus.rotduring;

%move stage into position
zaber.axis(p.trial.stimulus.orthaxis).moveAbsolute(p.trial.stimulus.orthoff(1),Units.LENGTH_MILLIMETRES);
zaber.axis(p.trial.stimulus.paraxis).moveAbsolute(p.trial.stimulus.paroff,Units.LENGTH_MILLIMETRES);
zaber.axis(p.trial.stimulus.rotaxis).moveAbsolute(p.trial.stimulus.rotangle,Units.ANGLE_DEGREES);


Screen('FillRect',p.trial.display.ptr,[192 192 192]);

%set state
p.trial.state=p.trial.stimulus.states.START;

%set ports correctly
pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT p.trial.stimulus.side.MIDDLE],0,p);




%% ------------------------------------------------------------------%
%display stats at end of trial
function cleanUpandSave(p)
tic
disp('----------------------------------')
disp(['Trialno: ' num2str(p.trial.pldaps.iTrial)])

%show reward amount
if p.trial.pldaps.draw.reward.show
    pds.behavior.reward.showReward(p,{'S';'L';'R'})
end

%show frac instruct
disp(['FI: ' num2str(p.trial.stimulus.fracInstruct)]);


%+/- frac instruct
if p.trial.userInput==1
    p.trialMem.fracInstruct = p.trial.stimulus.fracInstruct - 0.1;
    disp('decreased fracInstruct')
end
if p.trial.userInput==2
    p.trialMem.fracInstruct = p.trial.stimulus.fracInstruct + 0.1;
    disp('increased fracInstruct')
end
if p.trial.userInput==3
    p.trialMem.fracInstruct = 1;
    p.trialMem.count = 0;
    disp('increased fracInstruct to 1, effective immediately')
end

%show stats
pds.behavior.countTrial(p,p.trial.pldaps.goodtrial);
num2str(vertcat(p.trialMem.stats.val,p.trialMem.stats.count.Ntrial,...
    p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100))


% disp(['C: ' num2str(p.trialMem.stats.val)])
% disp(['N: ' num2str(p.trialMem.stats.count.Ntrial)])
% disp(['P: ' num2str(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100)])



%%%%%%Helper functions
%-------------------------------------------------------------------%
%check whether a particular port choice is correct
function correct=checkPortChoice(activePort,p)

correct=0;

switch p.trial.side
    case p.trial.stimulus.side.LEFT
        if activePort==p.trial.stimulus.side.LEFT
            correct=1;
            p.trial.stimulus.switchVAR = 1;
        end
    case p.trial.stimulus.side.RIGHT
        if activePort==p.trial.stimulus.side.RIGHT
            correct=1;
            p.trial.stimulus.switchVAR = 2;
        end
end

