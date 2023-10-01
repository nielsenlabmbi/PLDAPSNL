function perim_trial_free(p,state)

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
            Screen(p.trial.display.ptr, 'FillRect', p.trial.display.bgColor);
        elseif p.trial.state==p.trial.stimulus.states.STIMON
            showStimulus(p);
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
            pds.LED.AnyLEDOn(p,23);
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
            if p.trial.stimulus.midpointIR %needs to cross midline first to show stimulus
                p.trial.state=p.trial.stimulus.states.MOVE;
            else %immediately show stimulus
                p.trial.state=p.trial.stimulus.states.STIMON;
            end
        end
    
    case p.trial.stimulus.states.MOVE %wait for ferret to cross midline
        if activePort==p.trial.stimulus.port.MIDDLE
            %note time
            p.trial.stimulus.timeCrossML = p.trial.ttime;
            p.trial.stimulus.frameCrossML = p.trial.iFrame;
            %advance state
            p.trial.state=p.trial.stimulus.states.WAITSTART;
        end

    case p.trial.stimulus.states.WAITSTART %wait for time offset

        if p.trial.ttime > p.trial.stimulus.timeCrossML + p.trial.stimulus.startStim
            p.trial.state=p.trial.stimulus.states.STIMON;
        end

    case p.trial.stimulus.states.STIMON %stimulus shown; port selected in response
        %check whether left or right port chosen
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
                else
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
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
            
            p.trialMem.correct = p.trialMem.correct + 1;

            %advance state, mark as correct trial and flag next trial
            p.trial.state=p.trial.stimulus.states.TRIALCOMPLETE;
            p.trial.pldaps.goodtrial = 1;
            p.trial.flagNextTrial = true;
        end
        
    case p.trial.stimulus.states.INCORRECT %incorrect port selected for stimulus
        if p.trial.stimulus.forceCorrect == 1 %must give correct response before ending trial            
            %check whether any port chosen
            if ismember(activePort, [p.trial.stimulus.port.LEFT p.trial.stimulus.port.RIGHT])
                %check whether correct port chosen
                correct=checkPortChoice(activePort,p);                
                if correct==1 %now has chosen correct port
                    %note time
                    p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                    p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
                    pds.LED.AnyLEDOff(p,23);
                    
                    if activePort==p.trial.stimulus.port.LEFT
                        amount=p.trial.behavior.reward.propAmtIncorrect*p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                    else
                        amount=p.trial.behavior.reward.propAmtIncorrect*p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
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
%% setup trial parameters, prep stimulus as far as possible
function p=trialSetup(p)
    
    if isfield(p.trial,'masktxtr')
        Screen('Close',p.trial.masktxtr);
    end
    p.trial.masktxtr=[];
    
    if isfield(p.trial,'gtxtr')
        Screen('Close',p.trial.gtxtr)
    end
    p.trial.gtxtr=[];
    
    %get side for condition
    switch p.conditions{p.trial.pldaps.iTrial}.side
        case 1
            p.trial.side=p.trial.stimulus.side.LEFT;
        case 2
            p.trial.side=p.trial.stimulus.side.RIGHT;
        case 3
            p.trial.side=p.trial.stimulus.side.MIDDLE;
    end
    
    %set up trialMem fields if needed
    if ~isfield(p.trialMem,'correct')
        p.trialMem.correct = 0;
    end
    if ~isfield(p.trialMem,'durStim')
        p.trialMem.durStim=p.trial.stimulus.durStim;
    end
    if ~isfield(p.trialMem,'dotColor')
        p.trialMem.dotColor = 1; %required for flashing dot (1 = default, 0 = flash color)
    end

    % set up stimulus    
    DegPerPix = p.trial.display.dWidth/p.trial.display.pWidth;
    PixPerDeg = 1/DegPerPix;
      
    %dot size in pixels
    p.trial.stimulus.dotSizePix = round(p.trial.stimulus.dotSize*PixPerDeg);
    
    %dot position
    p.trial.stimulus.offset = p.conditions{p.trial.pldaps.iTrial}.offset;
    p.trial.stimulus.stimSide = p.conditions{p.trial.pldaps.iTrial}.stimSide;
    p.trial.stimulus.randPos = p.conditions{p.trial.pldaps.iTrial}.randPos;
    centerX = round(p.trial.display.pWidth/2)+...
        p.conditions{p.trial.pldaps.iTrial}.stimSide*p.conditions{p.trial.pldaps.iTrial}.offset;
    
    if p.trial.stimulus.randPos==1
        %choose random position
        %positions come from a grid of possible positions
        x=[0:p.trial.stimulus.posSpacing:p.trial.stimulus.windowWidth];
        y=[0:p.trial.stimulus.posSpacing:p.trial.stimulus.windowHeight];
        [xpos,ypos]=meshgrid(x,y);
        xpos=xpos(:);
        ypos=ypos(:);
        posidx=randi(length(xpos));
        p.trial.dotposX=centerX+xpos(posidx);
        p.trial.dotposY=p.trial.stimulus.centerY+ypos(posidx);
    else
        %fixed position
        p.trial.dotposX=centerX;
        p.trial.dotposY=p.trial.stimulus.centerY;
    end
    

    %frames
    p.trial.stimulus.frameI = 0;
    p.trial.stimulus.nrFrames=p.trial.stimulus.durStim*p.trial.stimulus.frameRate;
          
    %set state
    p.trial.state=p.trial.stimulus.states.START;
    if p.trial.camera.use
        pds.behavcam.startcam(p);
    end

%------------------------------------------------------------------%
%% show stimulus 
function showStimulus(p)
    p.trial.stimulus.frameI=p.trial.stimulus.frameI+1;
    if p.trial.stimulus.frameI<=p.trial.stimulus.nrFrames
        
        %flash dot if necessary (will go to flash color)
        p.trial.stimulus.dotColor=p.trial.stimulus.dotColor;
        if p.trial.stimulus.flashDot==1
            if mod(p.trial.stimulus.frameI,p.trial.stimulus.flashRate)==0
                p.trialMem.dotColor=~p.trialMem.dotColor;
            end
            if p.trialMem.dotColor==1
                p.trial.stimulus.dotColor=p.trial.stimulus.dotColor;
            else
                p.trial.stimulus.dotColor=p.trial.stimulus.flashColor;
            end
        end

        Screen('DrawDots', p.trial.display.ptr, [p.trial.stimulus.dotposX;p.trial.stimulus.dotposY], ...
            p.trial.stimulus.dotSizePix, p.trial.stimulus.dotColor,[],1);
    end

%------------------------------------------------------------------%
%% display stats at end of trial
function cleanUpandSave(p)
    %stop camera and set trigger to low
    pds.behavcam.stopcam(p);
    pds.behavcam.triggercam(p,0);
    
    pds.LED.AnyLEDOff(p,23);
    
    disp('----------------------------------')
    disp(['Trialno: ' num2str(p.trial.pldaps.iTrial)])
    %show reward amount
    if p.trial.pldaps.draw.reward.show
        pds.behavior.reward.showReward(p,{'S';'L';'R';'M'})
    end
    
    %show stats
    pds.behavior.countTrial(p,p.trial.pldaps.goodtrial);
    %num2str(vertcat(p.trialMem.stats.val,p.trialMem.stats.count.Ntrial,...
    %    p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100))
    
   
    disp(num2str(vertcat(p.trialMem.stats.val,p.trialMem.stats.count.Ntrial,...
        p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100)))
    
    
    %change stimulus duration if needed
    if p.trial.userInput==1
        p.trialMem.durStim=p.trialMem.durStim+0.1;
        disp(['increased stim dur to ' num2str(p.trialMem.durStim)])
    end
    if p.trial.userInput==2
        p.trialMem.durStim=p.trialMem.durStim-0.1;
        disp(['decreased stim dur to ' num2str(p.trialMem.durStim)]')
    end

    

%% Helper functions
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
        case p.trial.stimulus.side.MIDDLE
            if activePort==p.trial.stimulus.port.MIDDLE
                correct=1;
            end
    end