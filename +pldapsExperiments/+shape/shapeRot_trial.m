 function shapeRot_trial(p,state)
%%%Doty et al shape discrimination - one positive, one negative shape 

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
            Screen(p.trial.display.ptr, 'FillRect', 0)
        elseif p.trial.state==p.trial.stimulus.states.STIMON || p.trial.state==p.trial.stimulus.states.INCORRECT
            showStimulus(p);

        end
     
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        cleanUpandSave(p);
        
end


 

%-------------------------------------------------------------------%
%check port status and set events accordingly
function p=checkState(p)

activePort=find(p.trial.ports.status==1);
%disp(activePort)

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
        if ismember(activePort, [p.trial.stimulus.port.LEFT p.trial.stimulus.port.RIGHT])
            %note time
            p.trial.stimulus.timeTrialFirstResp = p.trial.ttime;
            p.trial.stimulus.frameTrialFirstResp = p.trial.iFrame;
        
            %note response
            %p.trial.stimulus.respTrial=activePort;
            p.trial.stimulus.respTrial=p.trial.ports.status;
            
            %check whether correct port chosen
            correct=checkPortChoice(activePort,p);
            if correct==1
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
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.MIDDLE);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.MIDDLE);
                end
                %advance state
                p.trial.state=p.trial.stimulus.states.CORRECT;
            else
                %play tone
                pds.audio.playDatapixxAudio(p,'breakfix');
                %advance state
                p.trial.state=p.trial.stimulus.states.INCORRECT;
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
        
    case p.trial.stimulus.states.INCORRECT %incorrect port selected for stimulus
        p.trial.pldaps.goodtrial = 0; 
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
                        amount=p.trial.behavior.reward.propAmtIncorrect*p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                    elseif activePort==p.trial.stimulus.port.RIGHT
                        amount=p.trial.behavior.reward.propAmtIncorrect*p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
                    else
                        amount=p.trial.behavior.reward.propAmtIncorrect*p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.MIDDLE);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.MIDDLE);
                    end
                    
                    %advance state
                    p.trial.state=p.trial.stimulus.states.FINALRESP;
                    
                end
            end
                
        else %incorrect responses end trial immediately
            %wait for ITI
            if p.trial.ttime > p.trial.stimulus.timeTrialFirstResp + p.trial.stimulus.duration.ITI
                %trial done
                p.trial.state=p.trial.stimulus.states.TRIALCOMPLETE;
                p.trial.flagNextTrial = true;
            end
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
%setup trial parameters, prep stimulus as far as possible (here: compute
%polygon coordinates)
function p=trialSetup(p)



%get side for condition
if p.conditions{p.trial.pldaps.iTrial}.side==2
    p.trial.side=p.trial.stimulus.side.LEFT;
else
    p.trial.side=p.trial.stimulus.side.RIGHT;
end

centerPosX=p.trial.display.pWidth/2;
centerPosY=800;

%read images - only do this on the first trial
if ~isfield(p.trialMem,'posImg')
    %positive shape
    imgPos=imread(fullfile(p.trial.stimulus.imgBase,...
        [p.trial.stimulus.posImg '.' p.trial.stimulus.filetype]));
    imgPos=double(squeeze(imgPos(:,:,1)));
    %imgPos=imgPos./255;
    p.trialMem.posImgSize=size(imgPos);
    p.trialMem.posImg = Screen(p.trial.display.ptr, 'MakeTexture', imgPos);
end

if ~isfield(p.trialMem,'negImg')
    %negative shape
    imgNeg=imread(fullfile(p.trial.stimulus.imgBase,...
        [p.trial.stimulus.negImg '.' p.trial.stimulus.filetype]));
    imgNeg=double(squeeze(imgNeg(:,:,1)));
    %imgNeg=imgNeg./255;
    p.trialMem.negImgSize=size(imgNeg);
    p.trialMem.negImg = Screen(p.trial.display.ptr, 'MakeTexture', imgNeg);
end


%determine plotting positions
stimDstT = [0 0 p.trialMem.posImgSize(2)-1 p.trialMem.posImgSize(1)-1];
p.trial.stimulus.stimSrcPos=stimDstT;
if p.trial.side==p.trial.stimulus.side.LEFT
    p.trial.stimulus.stimDstPos=CenterRectOnPoint(stimDstT,centerPosX-p.trial.stimulus.shapeOffset,centerPosY);
else
    p.trial.stimulus.stimDstPos=CenterRectOnPoint(stimDstT,centerPosX+p.trial.stimulus.shapeOffset,centerPosY);
end

stimDstT = [0 0 p.trialMem.negImgSize(2)-1 p.trialMem.negImgSize(1)-1];
p.trial.stimulus.stimSrcNeg=stimDstT;
if p.trial.side==p.trial.stimulus.side.LEFT
    p.trial.stimulus.stimDstNeg=CenterRectOnPoint(stimDstT,centerPosX+p.trial.stimulus.shapeOffset,centerPosY);
else
    p.trial.stimulus.stimDstNeg=CenterRectOnPoint(stimDstT,centerPosX-p.trial.stimulus.shapeOffset,centerPosY);
end

%determine rotation
switch p.conditions{p.trial.pldaps.iTrial}.rotType
    case 0 %no rotation
        p.trial.stimulus.rotPos=0;
        p.trial.stimulus.rotNeg=0;
    case 1 %positive shape only
        p.trial.stimulus.rotPos=p.conditions{p.trial.pldaps.iTrial}.rotPos;
        p.trial.stimulus.rotNeg=0;
    case 2 %negative shape only
        p.trial.stimulus.rotPos=0;
        p.trial.stimulus.rotNeg=p.conditions{p.trial.pldaps.iTrial}.rotNeg;
    case 3
        p.trial.stimulus.rotPos=p.conditions{p.trial.pldaps.iTrial}.rotPos;
        p.trial.stimulus.rotNeg=p.conditions{p.trial.pldaps.iTrial}.rotNeg;
end

p.trial.stimulus.frameI = 0;

%set state
p.trial.state=p.trial.stimulus.states.START;

%------------------------------------------------------------------%
%show stimulus - handles rotation and movement of grating
function showStimulus(p)

%positive
Screen('DrawTexture', p.trial.display.ptr, p.trialMem.posImg,...
    p.trial.stimulus.stimSrcPos,p.trial.stimulus.stimDstPos,p.trial.stimulus.rotPos);


%negative
Screen('DrawTexture', p.trial.display.ptr, p.trialMem.negImg,...
    p.trial.stimulus.stimSrcNeg,p.trial.stimulus.stimDstNeg,p.trial.stimulus.rotNeg);


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
num2str(vertcat(p.trialMem.stats.val,p.trialMem.stats.count.Ntrial,...
    round(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100,1)))

switch p.trial.userInput
    case 1
        p.trialMem.movAmpP=p.trialMem.movAmpP+p.trial.stimulus.stepAmp;
        disp(['increased pos amp to ' num2str(p.trialMem.movAmpP)])
    case 2
        p.trialMem.movAmpP=p.trialMem.movAmpP-p.trial.stimulus.stepAmp;
        disp(['decreased pos amp to ' num2str(p.trialMem.movAmpP)])
    case 3
        p.trialMem.movAmpN=p.trialMem.movAmpN+p.trial.stimulus.stepAmp;
        disp(['increased neg amp to ' num2str(p.trialMem.movAmpN)])
    case 4
        p.trialMem.movAmpN=p.trialMem.movAmpN-p.trial.stimulus.stepAmp;
        disp(['decreased neg amp to ' num2str(p.trialMem.movAmpN)])
end




    

%%%%%%Helper functions
%-------------------------------------------------------------------%
%check whether a particular port choice is correct
function correct=checkPortChoice(activePort,p)

correct=0;

switch p.trial.side
    case p.trial.stimulus.side.LEFT
        if activePort==p.trial.stimulus.port.LEFT
            correct=1;
        end
    case p.trial.stimulus.side.RIGHT
        if activePort==p.trial.stimulus.port.RIGHT
            correct=1;
        end
end