function shapeOutline_trial(p,state)
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
            %Screen('FillPoly',p.trial.display.ptr,[1 1 1],p.trial.stimulus.posCoord);
            %Screen('FillPoly',p.trial.display.ptr,[1 1 1],p.trial.stimulus.negCoord);
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


%positive shapes
%coordinates: matrix, row specifies x, y vertices
switch p.trial.stimulus.shapePos
    case 0 %plus sign
        shapeCoord=[0.5 1
            0.5 0.5
            1 0.5
            1 -0.5
            0.5 -0.5
            0.5 -1
            -0.5 -1
            -0.5 -0.5
            -1 -0.5
            -1 0.5
            -0.5 0.5
            -0.5 1];
    case 1 %star
        shapeCoord=[0 1
            0.25 0.25
            1 0.25
            0.4 -0.25
            0.7 -1
            0 -0.5
            -0.7 -1
            -0.4 -0.25
            -1 0.25
            -0.25 0.25];
    case 2 %pentagon
        shapeCoord=[0 0.7
            -1 0
            -0.6 -1.1
            0.6 -1.1
            1 0];
    case 3 %u
        shapeCoord=[-1 1
            1 1
            1 0
            0.6 0
            0.6 0.6
            -0.6 0.6
            -0.6 0
            -1 0];
        shapeCoord(:,2)=shapeCoord(:,2)*1.5-0.5;
end
shapeCoord=shapeCoord*p.trial.stimulus.shapeScale;
if p.trial.side==p.trial.stimulus.side.LEFT
    shapeCoord(:,1)=shapeCoord(:,1)+centerPosX-p.trial.stimulus.shapeOffset;
else
    shapeCoord(:,1)=shapeCoord(:,1)+centerPosX+p.trial.stimulus.shapeOffset;
end
shapeCoord(:,2)=shapeCoord(:,2)+centerPosY;
p.trial.stimulus.posCoord=shapeCoord;


%negative shape
switch p.trial.stimulus.shapeNeg
    case 0 %triangle
        shapeCoord=[0 1
            1 -0.5
            -1 -0.5];
    case 1 %square
        shapeCoord=[-0.7 0.7
            0.7 0.7
            0.7 -0.7
            -0.7 -0.7];
    case 2 %heart
        shapeCoord=[-0.6 1
            -1.2 0.8
            -0.6 0
            0 -1
            0.6 0
            1.2 0.8
            0.6 1
            0 0.6];
    case 3 %S
        shapeCoord=[-1 1
            1 1
            1 0.7
            0.4 0.7
            0.4 0.3
            1 0.3
            1 0
            -1 0
            -1 0.3
            -0.4 0.3
            -0.4 0.7
            -1 0.7];
        shapeCoord(:,2)=shapeCoord(:,2)*1.5-0.5;
end
shapeCoord=shapeCoord*p.trial.stimulus.shapeScale;
%move to opposite side from positive
if p.trial.side==p.trial.stimulus.side.LEFT
    shapeCoord(:,1)=shapeCoord(:,1)+centerPosX+p.trial.stimulus.shapeOffset;
else
    shapeCoord(:,1)=shapeCoord(:,1)+centerPosX-p.trial.stimulus.shapeOffset;
end
shapeCoord(:,2)=shapeCoord(:,2)+centerPosY;
p.trial.stimulus.negCoord=shapeCoord;

if ~isfield(p.trialMem,'movAmpP')
    p.trialMem.movAmpP=p.trial.stimulus.movAmpP;
end
if ~isfield(p.trialMem,'movAmpN')
    p.trialMem.movAmpN=p.trial.stimulus.movAmpN;
end

p.trial.stimulus.frameI = 0;

%set state
p.trial.state=p.trial.stimulus.states.START;

%------------------------------------------------------------------%
%show stimulus - handles rotation and movement of grating
function showStimulus(p)

%make the positive stimulus move if selected
p.trial.stimulus.frameI=p.trial.stimulus.frameI+1;

if p.trial.stimulus.mov==1
    offsetP=sin(2*pi*p.trial.stimulus.frameI/p.trial.stimulus.movFreq);
    offsetP=offsetP.*p.trialMem.movAmpP;
else
    offsetP=0;
end

if p.trial.stimulus.mov==1
    offsetN=sin(2*pi*p.trial.stimulus.frameI/p.trial.stimulus.movFreq);
    offsetN=offsetN.*p.trialMem.movAmpN;
else
    offsetN=0;
end

if p.conditions{p.trial.pldaps.iTrial}.shapeType==0
    Screen('FillPoly',p.trial.display.ptr,[1 1 1],p.trial.stimulus.posCoord+offsetP);
    Screen('FillPoly',p.trial.display.ptr,[1 1 1],p.trial.stimulus.negCoord+offsetN);
else
    penW=p.trial.stimulus.lineWidth;
    Screen('FramePoly',p.trial.display.ptr,[1 1 1],p.trial.stimulus.posCoord+offsetP,penW);
    Screen('FramePoly',p.trial.display.ptr,[1 1 1],p.trial.stimulus.negCoord+offsetN,penW);
end

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