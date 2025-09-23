function lesion_dots_trial_P6A(p,state)
%This phase adjusts the stimulus duration

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
            showStimulus(p); %we adjust duration in this function
            
        end
     
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        cleanUpandSave(p);
        
end


 

%-------------------------------------------------------------------%
%check port status and set events accordingly
function p=checkState(p)

activePort=find(p.trial.ports.status==1);

%remove exit port from trial.port.status list since it is triggered with
%other ports in too many instances, with the exception of the state we need
%it in
if p.trial.state ~= p.trial.stimulus.states.STIMON
    activePort=activePort(activePort~=p.trial.stimulus.port.EXIT);
end


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
            if p.trial.stimulus.midpointIR %needs to cross midline first to show stimulus
                p.trial.state=p.trial.stimulus.states.MOVE;
            else %immediately show stimulus
                p.trial.state=p.trial.stimulus.states.STIMON;
            end
        end

    case p.trial.stimulus.states.MOVE %wait for ferret to cross midline
        if activePort==p.trial.stimulus.port.MIDDLE
            %advance state
            p.trial.stimulus.timeStimOn= p.trial.ttime;
            p.trial.stimulus.frameStimOn = p.trial.iFrame;
            p.trial.state=p.trial.stimulus.states.STIMON;
            pds.LED.stimLEDOn(p);
        end
        
    case p.trial.stimulus.states.STIMON
        if ismember(p.trial.stimulus.port.EXIT, activePort)
            p.trial.stimulus.timeExitCross = p.trial.ttime;
            p.trial.stimulus.frameExitCross = p.trial.iFrame;
            p.trial.state=p.trial.stimulus.states.STIMOFF;
            pds.LED.stimLEDOff(p);
        end

    case p.trial.stimulus.states.STIMOFF %stimulus shown; port selected in response
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
    
    if ~isfield(p.trialMem,'condIdx')
        p.trialMem.condIdx=1;
    end

    if ~isfield(p.trialMem,'matchType')
        p.trialMem.matchType=p.trial.stimulus.iniMatchType;
    end

    % set up stimulus    
    DegPerPix = p.trial.display.dWidth/p.trial.display.pWidth;
    PixPerDeg = 1/DegPerPix;
    
    %transform stimulus sizes into px
    p.trial.stimulus.height=p.trial.stimulus.width;
    p.trial.stimulus.pWidth=round(p.trial.stimulus.width*PixPerDeg);
    p.trial.stimulus.pHeight=p.trial.stimulus.pWidth;

    %determine direction and side; we'll keep direction and adjust side as
    %needed for match condition
    %direction is tethered to response side, using that to make code
    %simpler

    sideResp=p.conditions{p.trial.pldaps.iTrial}.side;
    p.trial.stimulus.dir = p.trial.stimulus.direction(sideResp);

    %figure out side based on match type
    switch p.trialMem.matchType
        case 0 %full cross
            
            p.trialMem.condIdx=p.conditions{p.trial.pldaps.iTrial}.condIdx; %we need this for counting
            sideIdx = mod(p.trialMem.condIdx-1,2)+1; %cond 1, 3 = L = side 1, cond 2, 4 = R = side 2
            p.trial.stimulus.sSide = p.trial.stimulus.stimSide(sideIdx);
             
        case 1 % either 0 & R, or 180 & L
            if p.trial.stimulus.dir == 0
                p.trial.stimulus.sSide = 1;
                %overwrite condition idx to end up in the correct counter
                %bin
                p.trialMem.condIdx=2;
            elseif p.trial.stimulus.dir == 180
                p.trial.stimulus.sSide = -1;
                p.trialMem.condIdx=3;
            end
        case 2 % either 0 & L, or 180 & R
            if p.trial.stimulus.dir == 0
                p.trial.stimulus.sSide = -1;
                p.trialMem.condIdx=1;
            elseif p.trial.stimulus.dir == 180
                p.trial.stimulus.sSide = 1;
                p.trialMem.condIdx=4;
            end
    end

    %stimulus center
    p.trial.stimulus.centerX = p.trial.display.pWidth/2;
    p.trial.stimulus.offsetPx=round(p.trial.stimulus.offset*PixPerDeg);
    p.trial.stimulus.centerX=p.trial.stimulus.centerX+...
        p.trial.stimulus.sSide*p.trial.stimulus.offsetPx;


        
    %number of dots - density is in dots/deg^2, size in deg
    p.trial.stimulus.nrDots=round(p.trial.stimulus.dotDensity*p.trial.stimulus.width*...
        p.trial.stimulus.height);
    
    %dot size
    p.trial.stimulus.dotSizePix = round(p.trial.stimulus.dotSize*PixPerDeg);
    
    %dot displacement per frame (speed is in deg/sec)
    p.trial.stimulus.deltaF=p.trial.stimulus.dotSpeed/p.trial.stimulus.frameRate*PixPerDeg;
    
    %dot lifetime in frames (lifetime is in ms)
    p.trial.stimulus.dotLifeFr = round(p.trial.stimulus.dotLifetime*p.trial.stimulus.frameRate/1000);
           

    %initialize frame
    p.trial.stimulus.frameI = 0;
    
    %initialize dot positions - these need to be in pixels from center
    randpos=rand(2,p.trial.stimulus.nrDots); %this gives numbers between 0 and 1
    randpos(1,:)=(randpos(1,:)-0.5)*p.trial.stimulus.pWidth;
    randpos(2,:)=(randpos(2,:)-0.5)*p.trial.stimulus.pHeight;
    
    %initialize noise vector
    nrSignal=round(p.trial.stimulus.nrDots*p.trial.stimulus.dotCoherence);
    noisevec=zeros(p.trial.stimulus.nrDots,1);
    noisevec(1:nrSignal)=1;
    
    %initialize directions: correct displacement for signal, random for noise
    %side is either 1 or 2; 1 should equal direction=0, 2 direction=180
    randdir=zeros(p.trial.stimulus.nrDots,1);
    randdir(1:end)=p.trial.stimulus.dir;
    idx=find(noisevec==0);
    randdir(idx)=randi([0,359],length(idx),1);
    
    
    %initialize lifetime vector
    if p.trial.stimulus.dotLifeFr>0
        lifetime=randi(p.trial.stimulus.dotLifeFr,p.trial.stimulus.nrDots,1);
    end
    
    %compute nr frames
    p.trial.stimulus.nrFrames=p.trial.stimulus.durStim*p.trial.stimulus.frameRate;
    
    %save misc variables
    p.trial.stimulus.randpos = randpos;
    p.trial.stimulus.randdir = randdir;
    p.trial.stimulus.lifetime = lifetime;
    
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
        f = p.trial.stimulus.frameI;
        randpos = p.trial.stimulus.randpos;
        randdir = p.trial.stimulus.randdir;
        deltaF = p.trial.stimulus.deltaF;
        lifetime = p.trial.stimulus.lifetime;
        %compute vectors for necessary frames
        %move all dots according to their direction
        xproj=-cos(randdir*pi/180);
        yproj=-sin(randdir*pi/180);
    
        randpos(1,:)=randpos(1,:)+deltaF*xproj';
        randpos(2,:)=randpos(2,:)+deltaF*yproj';
    
        %now deal with wrap around - we pick the axis on which to replot a dot
        %based on the dots direction
        idx=find(abs(randpos(1,:))>p.trial.stimulus.pWidth/2 | abs(randpos(2,:))>p.trial.stimulus.pHeight/2);
    
        rvec=rand(size(idx)); %btw 0 and 1
        for i=1:length(idx)
            if rvec(i)<=abs(xproj(idx(i)))/(abs(xproj(idx(i)))+abs(yproj(idx(i))))
                randpos(1,idx(i))=-1*sign(xproj(idx(i)))*p.trial.stimulus.pWidth/2;
                randpos(2,idx(i))=(rand(1)-0.5)*p.trial.stimulus.pHeight;
            else
                randpos(1,idx(i))=(rand(1)-0.5)*p.trial.stimulus.pWidth;
                randpos(2,idx(i))=-1*sign(yproj(idx(i)))*p.trial.stimulus.pHeight/2;
            end
        end
        
        %if lifetime is expired, randomly assign new direction
        if p.trial.stimulus.dotLifeFr>0
            idx=find(lifetime==0);
            %directions are drawn based on coherence level
            rvec=rand(size(idx));
            for i=1:length(idx)
                if rvec(i)<p.trial.stimulus.dotCoherence %these get moved with the signal
                    randdir(idx(i))=p.trial.stimulus.dir;
                else
                    randdir(idx(i))=randi([0,359],1,1);
                end
            end
    
            lifetime=lifetime-1;
            lifetime(idx)=p.trial.stimulus.dotLifeFr;
        end
        p.trial.stimulus.lifetime = lifetime;
        p.trial.stimulus.dotpos{f}=randpos;
        p.trial.stimulus.randpos = randpos;
        p.trial.stimulus.randdir = randdir;
        Screen('DrawDots', p.trial.display.ptr, p.trial.stimulus.dotpos{p.trial.stimulus.frameI}, ...
            p.trial.stimulus.dotSizePix, p.trial.stimulus.dotColor, ...
             [p.trial.stimulus.centerX p.trial.stimulus.centerY],1);

    end

%------------------------------------------------------------------%
%% display stats at end of trial
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
    pds.behavior.countTrialNew(p,p.trial.pldaps.goodtrial,1, p.trialMem.condIdx); %updates counters
    pds.behavior.printCounter(p.trialMem.stats.sideCounter,p.trialMem.stats.sideCounterNames)
    pds.behavior.printCounter(p.trialMem.stats.condCounter,p.trialMem.stats.condCounterNames)


    switch p.trial.userInput
        case 5 %M key
            p.trialMem.matchType = 2;
            disp('Matching Response Condition if [Bad% Good%][Good% Bad%]')
        case 6 %N key
            p.trialMem.matchType = 1;
            disp('Non-Matching Response Condition if [Good% Bad%][Bad% Good%]')
        case 7 %R key
            p.trialMem.matchType = 0;
            disp('All 4 Response Conditions')
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