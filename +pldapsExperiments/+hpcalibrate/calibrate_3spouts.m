function calibrate_3spouts(p,state)

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
        if p.trial.state==p.trial.stimulus.states.START & p.trial.stimulus.show
            Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.iniColor,p.trial.stimulus.iniSize);
        elseif p.trial.state==p.trial.stimulus.states.STIMON  & p.trial.stimulus.show || p.trial.state==p.trial.stimulus.states.INCORRECT & p.trial.stimulus.show
            Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.stimColor,p.trial.stimulus.stimSize);
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
        
        if p.trial.ttime > p.trial.stimulus.baseline && p.trial.ports.position(p.trial.stimulus.side.MIDDLE)==0
            pds.ports.movePort(p.trial.stimulus.side.MIDDLE,1,p);
        end
        
        %disp(['a: ' num2str(activePort)])
       % disp(['s: ' num2str(p.trial.stimulus.port.START)])
        if activePort==p.trial.stimulus.port.START %start port activated
            %deliver reward
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.START);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.START);
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
            p.trial.stimulus.switchVAR = 0;
%                     
%                 pds.datapixx.analogOutTime(0, 1, 0, p.trial.datapixx.dac.sampleRate);  
%                 pds.datapixx.analogOutTime(0, 2, 0, p.trial.datapixx.dac.sampleRate);  
%                 pds.datapixx.analogOutTime(0, 3, 0, p.trial.datapixx.dac.sampleRate);  

        end
        
    case p.trial.stimulus.states.LICKDELAY
        switch p.trial.stimulus.switchVAR
            case 0
                
                if p.trial.ttime < p.trial.stimulus.timeTrialStartResp + 0.5 & activePort==p.trial.stimulus.port.START %start port activated
                    %deliver reward
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.START);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.START);
                    
                end
                
                
                if p.trial.ttime > p.trial.stimulus.timeTrialStartResp + 0.5;
                if p.trial.ports.position(p.trial.stimulus.side.MIDDLE)==1
                    pds.ports.movePort(p.trial.stimulus.side.MIDDLE,0,p);
                end
                p.trial.stimulus.timeTrialWait = p.trial.ttime;
                p.trial.state=p.trial.stimulus.states.WAIT;
                end
            case 1
                %.trial.count = 0;
            %give reward
                if p.trial.ttime < p.trial.stimulus.timeResp + p.trial.stimulus.lickdelay & activePort==p.trial.stimulus.port.RIGHT... 
                    %& activePort == p.trial.side %& p.trial.count < 3
                    %deliver reward
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
                    %p.trial.count = p.trial.count + 1;
                end
                
                if p.trial.ttime < p.trial.stimulus.timeResp + p.trial.stimulus.lickdelay & activePort==p.trial.stimulus.port.LEFT ...
                    %& activePort == p.trial.side %& p.trial.count < 3
                    %deliver reward
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                    %p.trial.count = p.trial.count + 1;
                end
                
                if p.trial.ttime > p.trial.stimulus.timeResp + p.trial.stimulus.lickdelay;
                if any(p.trial.ports.position)
                    pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT],0,p);
                end
                p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
                p.trial.state=p.trial.stimulus.states.FINALRESP;
                end
            
            case 2
            
            if p.trial.ttime > p.trial.stimulus.timeResp + p.trial.stimulus.forceCorrect_delay;
                if any(p.trial.ports.position)
                    pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT],0,p);
                end
                p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
                p.trial.state=p.trial.stimulus.states.FINALRESP; 
            end
          
        end
        
    case p.trial.stimulus.states.WAIT
        if p.trial.ttime > p.trial.stimulus.timeTrialWait + p.trial.stimulus.waitTime;
                p.trial.stimulus.timeTrialStimOn = p.trial.ttime;
                p.trial.state=p.trial.stimulus.states.STIMON;
        end
        
    case p.trial.stimulus.states.STIMON %stimulus shown; port selected in response
        
         %wait to make ports available
        if p.trial.ttime > p.trial.stimulus.timeTrialStimOn + p.trial.stimulus.stimON && p.trial.ports.position(p.trial.stimulus.side.LEFT)==0 && p.trial.ports.position(p.trial.stimulus.side.RIGHT)==0;
            pds.ports.movePort(p.trial.side,1,p);
            pds.ports.movePort(1 + mod(p.trial.side,2),p.trial.ports.moveBool,p);
            %             pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT],1,p);
        end
        
        
        %check whether any port chosen
        if length(activePort) > 1 %if more than one port is activated
            
            %play tone
                pds.audio.playDatapixxAudio(p,'breakfix');
            %retract spouts
            pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT p.trial.stimulus.side.MIDDLE],0,p);
            %wait
            WaitSecs(4);
            %present spouts again
            pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT],1,p);
            
                
        
        elseif length(activePort) == 1 & activePort==p.trial.stimulus.port.LEFT | activePort==p.trial.stimulus.port.RIGHT
            %note time
            p.trial.stimulus.timeTrialFirstResp = p.trial.ttime;
            p.trial.stimulus.frameTrialFirstResp = p.trial.iFrame;
        
            %note response
            p.trial.stimulus.respTrial=p.trial.ports.status;
            
            %check whether correct port chosen
            correct=checkPortChoice(activePort,p);
            if correct==1
                %play tone
                pds.audio.playDatapixxAudio(p,'reward_short');
                
               %retract incorrect spout, deliver reward
                if activePort==p.trial.stimulus.port.LEFT 
                    
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                    if p.trial.ports.position(p.trial.stimulus.side.RIGHT)==1
                        pds.ports.movePort(p.trial.stimulus.side.RIGHT,0,p);
                    end
                end
                if activePort==p.trial.stimulus.port.RIGHT 
                    
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
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
                    %give (small) reward                
                    if p.trial.ttime < p.trial.stimulus.timeResp + p.trial.stimulus.forceCorrect_delay & activePort==p.trial.stimulus.port.RIGHT 
                        %deliver reward
                        amount=2*p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
                        
                    end
                    
                    if p.trial.ttime < p.trial.stimulus.timeResp + p.trial.stimulus.forceCorrect_delay & activePort==p.trial.stimulus.port.LEFT 
                        %deliver reward
                        amount=2*p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                        
                    end
%                     if activePort==p.trial.stimulus.port.LEFT
%                         for i = 1:2
%                             amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
%                             pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
%                         end
%                     elseif activePort==p.trial.stimulus.port.RIGHT
%                         for i = 1:2
%                             amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
%                             pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
%                         end
%                     end
%                     
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
        
                pds.datapixx.analogOutTime(0, 1, 0, p.trial.datapixx.dac.sampleRate);  
                pds.datapixx.analogOutTime(0, 2, 0, p.trial.datapixx.dac.sampleRate);  
                pds.datapixx.analogOutTime(0, 3, 0, p.trial.datapixx.dac.sampleRate);  
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
if p.conditions{p.trial.pldaps.iTrial}.side==2
    p.trial.side=p.trial.stimulus.side.LEFT;
else
    p.trial.side=p.trial.stimulus.side.RIGHT;
end
if isfield(p.trialMem,'fracInstruct');
    p.trial.stimulus.fracInstruct = p.trialMem.fracInstruct;
end
%determine which spouts are presented when stimulus is presented
p.trial.ports.moveBool = double(rand > p.trial.stimulus.fracInstruct);

%set up initialization stimulus (this could be in settings file)
p.trial.stimulus.iniColor=1;
p.trial.stimulus.iniSize=[910 490 1010 590];
p.trial.stimulus.waitColor = 0.5;

%% set up stimulus


%set up initialization stimulus (this could be in settings file)
p.trial.stimulus.iniColor=1;
p.trial.stimulus.iniSize=[500 500 600 600];

%set up stimulus
p.trial.stimulus.stimColor=p.conditions{p.trial.pldaps.iTrial}.color;
p.trial.stimulus.stimSize=[450 200 1500 880];

%set state
p.trial.state=p.trial.stimulus.states.START;

%set ports correctly
pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT p.trial.stimulus.side.MIDDLE],0,p);


%show stimulus - handles rotation and movement of grating

%------------------------------------------------------------------%
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
disp(p.trial.stimulus.fracInstruct);


%+/- frac instruct
if p.trial.userInput==1
    p.trialMem.fracInstruct = p.trial.stimulus.fracInstruct - 0.3;
    disp('decreased fracInstruct')
end
if p.trial.userInput==2
    p.trialMem.fracInstruct = p.trial.stimulus.fracInstruct + 0.3;
    disp('increased fracInstruct')
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
        if activePort==p.trial.stimulus.side.LEFT |  activePort==p.trial.stimulus.port.RIGHT
            correct=1;
            p.trial.stimulus.switchVAR = 1;
        end
    case p.trial.stimulus.side.RIGHT
        if activePort==p.trial.stimulus.port.RIGHT | activePort==p.trial.stimulus.side.LEFT
            correct=1;
            p.trial.stimulus.switchVAR = 2; 
        end
end

