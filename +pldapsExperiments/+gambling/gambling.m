function gambling(p,state)

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
        if p.trial.state==p.trial.stimulus.states.START || p.trial.state==p.trial.stimulus.states.STIMON || p.trial.state == p.trial.stimulus.states.INCORRECT
          Screen(p.trial.display.ptr, 'FillRect', 0.5)
%         elseif p.trial.state==p.trial.stimulus.states.STIMON || p.trial.state==p.trial.stimulus.states.INCORRECT
%            % Screen(p.trial.display.ptr, 'FillRect', p.trial.stimulus.bgColor)
%             Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.test.stimColor,p.trial.stimulus.test.stimSize);
%             Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.ref.stimColor,p.trial.stimulus.ref.stimSize);
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
            if p.trial.camera.use 
                pds.behavcam.triggercam(p,1);
                p.trial.stimulus.timeCamOn = p.trial.ttime;
                p.trial.stimulus.frameCamOn = p.trial.iFrame;
            end
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
        if ismember(activePort, [p.trial.stimulus.port.MIDDLE p.trial.stimulus.port.LEFT p.trial.stimulus.port.RIGHT])
            %note time
            p.trial.stimulus.timeTrialFirstResp = p.trial.ttime;
            p.trial.stimulus.frameTrialFirstResp = p.trial.iFrame;
        
            %note response
            %p.trial.stimulus.respTrial=activePort;
            p.trial.stimulus.respTrial=p.trial.ports.status;
            if any(ismember(activePort,p.conditions{p.trial.pldaps.iTrial}.fixedPort));
                p.trialMem.fixedCount = p.trialMem.fixedCount + 1;
            elseif any(ismember(activePort,p.conditions{p.trial.pldaps.iTrial}.gamblePort));
                p.trialMem.gambleCount = p.trialMem.gambleCount + 1;
            end
                
                %mark as correct/incorrect, play tone
                correct=checkPortChoice(activePort,p);
                if correct
                    p.trial.pldaps.goodtrial = 1;
                    if p.trial.audio.use
                    pds.audio.playDatapixxAudio(p,'reward_short');
                    end
                    %give reward
                    amount = checkRewardAmount(activePort,p);
                    if activePort==p.trial.stimulus.port.LEFT
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                    elseif activePort==p.trial.stimulus.port.RIGHT
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
                    else
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.MIDDLE);
                    end
                        %advance state
                    p.trial.state=p.trial.stimulus.states.CORRECT;
                else
                    if p.trial.audio.use
                    pds.audio.playDatapixxAudio(p,'breakfix');
                    end
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
        if p.trial.stimulus.forceCorrect  %must give correct response before ending trial
            %check whether any port chosen
            if ismember(activePort, [p.trial.stimulus.port.MIDDLE p.trial.stimulus.port.LEFT p.trial.stimulus.port.RIGHT])
                %check whether correct port chosen
                correct=checkPortChoice(activePort,p);
                if correct==1 %now has chosen correct port
                    %note time
                    p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                    p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
                    amount=p.trial.behavior.reward.propAmtIncorrect*checkRewardAmount(activePort,p);
                    
                    if activePort==p.trial.stimulus.port.LEFT
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                    elseif activePort==p.trial.stimulus.port.RIGHT
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
                    else
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
            else
                pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.MIDDLE);
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
 
% %get gamble
% 
% if ~isfield(p.trialMem,'count') || p.trialMem.count == 0;
%     p.trialMem.count = 1;
%     p.trialMem.goodGamble = zeros(1,10);
%     p.trialMem.goodGamble(1:round((p.trial.stimulus.probability)*10)) = 1;
%     p.trialMem.goodGamble = p.trialMem.goodGamble(randperm(10));
% 
% end
% 
%     p.trial.goodGamble = p.trialMem.goodGamble(p.trialMem.count);
%     p.trialMem.count = mod(p.trialMem.count+1,11);
% 

if ~isfield(p.trialMem,'fixedCount')
    p.trialMem.fixedCount = 0;
end
if ~isfield(p.trialMem,'gambleCount')
    p.trialMem.gambleCount = 0;
end

% %set up stimulus
% p.trial.stimulus.test.stimColor=p.conditions{p.trial.pldaps.iTrial}.intensity;
% p.trial.stimulus.test.stimSize= [810 390 1110 690] + p.conditions{p.trial.pldaps.iTrial}.offset*[500 0 500 0];
% 
% p.trial.stimulus.ref.stimColor=p.conditions{p.trial.pldaps.iTrial}.reference;
% p.trial.stimulus.ref.stimSize = [810 390 1110 690] - p.conditions{p.trial.pldaps.iTrial}.offset*[500 0 500 0];

%set state
p.trial.state=p.trial.stimulus.states.START;

%get camera ready (there's a little bit of wait associated with this, so we
%have to do it here; the actual start happens with a trigger pulse when the
%led turns on)
if p.trial.camera.use;
    pds.behavcam.startcam(p);
end







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

% %show stats
% pds.behavior.countTrial(p,p.trial.pldaps.goodtrial);
% num2str(vertcat(p.trialMem.stats.val,p.trialMem.stats.count.Ntrial,...
%     p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100))

%show stats
pds.behavior.countTrial(p,p.trial.pldaps.goodtrial);
disp(['Reward amounts: ' num2str(p.trialMem.stats.val')])
disp(['Fixed/Gamble count: ' num2str([p.trialMem.fixedCount p.trialMem.gambleCount])])
disp(['Number of trials: ' num2str(p.trialMem.stats.count.Ntrial)])
disp(['%Correct: ' num2str(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100)])

    

%%%%%%Helper functions
%-------------------------------------------------------------------%
%check whether a particular port choice is correct
function correct=checkPortChoice(activePort,p)

if any(ismember(activePort,p.conditions{p.trial.pldaps.iTrial}.fixedPort))
    correct = 1;
elseif any(ismember(activePort,p.conditions{p.trial.pldaps.iTrial}.gamblePort)) 
    correct = 1*(rand < p.trial.stimulus.probability);
else
    correct = 0;
end


function amount = checkRewardAmount(activePort,p)
if any(ismember(activePort,p.conditions{p.trial.pldaps.iTrial}.fixedPort));
    idx = ismember(activePort,p.conditions{p.trial.pldaps.iTrial}.fixedPort);
    amount = p.conditions{p.trial.pldaps.iTrial}.fixedAmt(idx);
else
    idx = ismember(activePort,p.conditions{p.trial.pldaps.iTrial}.gamblePort);
    amount = p.conditions{p.trial.pldaps.iTrial}.gambleAmt(idx);
end