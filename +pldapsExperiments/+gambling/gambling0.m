function gambling0(p,state)

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
          % Screen(p.trial.display.ptr, 'FillRect', 0.5)
        elseif p.trial.state==p.trial.stimulus.states.STIMON || p.trial.state==p.trial.stimulus.states.INCORRECT
           % Screen(p.trial.display.ptr, 'FillRect', p.trial.stimulus.bgColor)
            Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.test.stimColor,p.trial.stimulus.test.stimSize);
            Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.ref.stimColor,p.trial.stimulus.ref.stimSize);
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
            %note timepoint
            p.trial.stimulus.timeTrialLedOn = p.trial.ttime;
            p.trial.stimulus.frameTrialLedOn = p.trial.iFrame;
            
            %send trigger pulse to camera
            pds.behavcam.triggercam(p,1);
            p.trial.stimulus.timeCamOn = p.trial.ttime;
            p.trial.stimulus.frameCamOn = p.trial.iFrame;
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
            
            %deliver reward
            amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.START);
            pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.START);
            
            %advance state
            p.trial.state=p.trial.stimulus.states.STIMON;
        end
        
    case p.trial.stimulus.states.STIMON %stimulus shown; port selected in response
        %check whether any port chosen
        if activePort==p.trial.stimulus.port.LEFT | activePort==p.trial.stimulus.port.RIGHT
            %note time
            p.trial.stimulus.timeTrialFirstResp = p.trial.ttime;
            p.trial.stimulus.frameTrialFirstResp = p.trial.iFrame;
        
            %note response
            %p.trial.stimulus.respTrial=activePort;
            p.trial.stimulus.respTrial=p.trial.ports.status;

                
                %mark as correct/incorrect, play tone
                correct=checkPortChoice(activePort,p);
                if correct==1
                    p.trial.pldaps.goodtrial = 1;
                    pds.audio.playDatapixxAudio(p,'reward_short');
                    %give reward
                    amount = checkRewardAmount(activePort,p);
                    if activePort==p.trial.stimulus.port.LEFT
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                    elseif activePort==p.trial.stimulus.port.RIGHT
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
                    end
                        %advance state
                    p.trial.state=p.trial.stimulus.states.CORRECT;
                else
                    pds.audio.playDatapixxAudio(p,'breakfix');
                    % advance state
                    p.trial.state = p.trial.stimulus.states.INCORRECT;
                end

        end
        
    case p.trial.stimulus.states.CORRECT %correct port selected for stimulus
        %wait for ITI
        if p.trial.ttime > p.trial.stimulus.timeTrialFirstResp + p.trial.stimulus.duration.ITI
            %trial done - note time
            p.trial.stimulus.timeTrialFinish = p.trial.ttime;
            p.trial.stimulus.frameTrialFinish = p.trial.iFrame;
            
            %advance state, mark as correct trial and flag next trial
            p.trial.state=p.trial.stimulus.states.TRIALCOMPLETE;
            p.trial.pldaps.goodtrial = 1;
            p.trial.flagNextTrial = true;
        end
        
    case p.trial.stimulus.states.INCORRECT
        if p.trial.stimulus.forceCorrect == 1 %must give correct response before ending trial
            %check whether any port chosen
            if ismember(activePort, [p.trial.stimulus.port.MIDDLE p.trial.stimulus.port.LEFT p.trial.stimulus.port.RIGHT])
                %check whether correct port chosen
                correct=checkPortChoice(activePort,p);
                if correct==1 %now has chosen correct port
                    %note time
                    p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                    p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
                    
                    if activePort==p.trial.stimulus.port.LEFT
                        amount=p.trial.behavior.reward.propAmtIncorrect*checkRewardAmount(activePort,p);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                    elseif activePort==p.trial.stimulus.port.RIGHT
                        amount=p.trial.behavior.reward.propAmtIncorrect*checkRewardAmount(activePort,p);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
                    else
                        amount=p.trial.behavior.reward.propAmtIncorrect*checkRewardAmount(activePort,p);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.MIDDLE);
                    end
                    %advance state
                    p.trial.state=p.trial.stimulus.states.FINALRESP;
                    
                end
            end
        else
            %note time
                    p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                    p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
            %give reward
            amount = checkRewardAmount(activePort,p);
            if activePort==p.trial.stimulus.port.LEFT
                pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
            elseif activePort==p.trial.stimulus.port.RIGHT
                pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
            end
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
 
%get side for condition
if p.conditions{p.trial.pldaps.iTrial}.side==1
    p.trial.side=p.trial.stimulus.side.LEFT;
else
    p.trial.side=p.trial.stimulus.side.RIGHT;
end

%set up initialization stimulus (this could be in settings file)
p.trial.stimulus.iniColor=1;
[910 490 1010 590];

%set up stimulus
p.trial.stimulus.test.stimColor=p.conditions{p.trial.pldaps.iTrial}.intensity;
p.trial.stimulus.test.stimSize= [810 390 1110 690] + p.conditions{p.trial.pldaps.iTrial}.offset*[500 0 500 0];

p.trial.stimulus.ref.stimColor=p.conditions{p.trial.pldaps.iTrial}.reference;
p.trial.stimulus.ref.stimSize = [810 390 1110 690] - p.conditions{p.trial.pldaps.iTrial}.offset*[500 0 500 0];

%set state
p.trial.state=p.trial.stimulus.states.START;

%get camera ready (there's a little bit of wait associated with this, so we
%have to do it here; the actual start happens with a trigger pulse when the
%led turns on
pds.behavcam.startcam(p);






%------------------------------------------------------------------%
%display stats at end of trial
function cleanUpandSave(p)

%stop camera and set trigger to low
pds.behavcam.stopcam(p);
pds.behavcam.triggercam(p,0);

disp('----------------------------------')
disp(['Trialno: ' num2str(p.trial.pldaps.iTrial)])
%show reward amount
if p.trial.pldaps.draw.reward.show
    pds.behavior.reward.showReward(p,{'S';'L';'R'})
end

%show stats
pds.behavior.countTrial(p,p.trial.pldaps.goodtrial);
num2str(vertcat(p.trialMem.stats.val,p.trialMem.stats.count.Ntrial,...
    p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100))

% %show stats
% pds.behavior.countTrial(p,p.trial.pldaps.goodtrial);
% disp(['C: ' num2str(p.trialMem.stats.val)])
% disp(['N: ' num2str(p.trialMem.stats.count.Ntrial)])
% disp(['P: ' num2str(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100)])

    

%%%%%%Helper functions
%-------------------------------------------------------------------%
%check whether a particular port choice is correct
function correct=checkPortChoice(activePort,p)

goodside = p.conditions{p.trial.pldaps.iTrial}.intensity > p.conditions{p.trial.pldaps.iTrial}.reference; 
sidetrue = 0;

switch p.trial.side
    case p.trial.stimulus.side.LEFT
        if activePort==p.trial.stimulus.port.LEFT
            sidetrue=1;
        end
    case p.trial.stimulus.side.RIGHT
        if activePort==p.trial.stimulus.port.RIGHT
            sidetrue=1;
        end
end
correct = sidetrue & goodside | ~sidetrue & ~goodside | p.conditions{p.trial.pldaps.iTrial}.intensity == p.conditions{p.trial.pldaps.iTrial}.reference;

function amount = checkRewardAmount(activePort,p)
switch p.trial.side
    case p.trial.stimulus.side.LEFT
        if activePort == p.trial.stimulus.side.LEFT
            amount = p.conditions{p.trial.pldaps.iTrial}.intensity/4 + 0.05;
        else
            amount = p.conditions{p.trial.pldaps.iTrial}.reference/4 + 0.05;
        end
    case p.trial.stimulus.side.RIGHT
        if activePort == p.trial.stimulus.side.RIGHT
            amount = p.conditions{p.trial.pldaps.iTrial}.intensity/4 + 0.05;
        else
            amount = p.conditions{p.trial.pldaps.iTrial}.reference/4 + 0.05;
        end
end