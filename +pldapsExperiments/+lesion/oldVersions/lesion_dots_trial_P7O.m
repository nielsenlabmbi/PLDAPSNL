function lesion_dots_trial_free_P6(p,state)

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
            %advance state
            p.trial.state=p.trial.stimulus.states.STIMON;
            pds.LED.stimLEDOn(p)
        end

        
    case p.trial.stimulus.states.STIMON %stimulus shown; port selected in response
        %check whether left or right port chosen
        if ismember(activePort, [p.trial.stimulus.port.LEFT p.trial.stimulus.port.RIGHT])
            pds.LED.stimLEDOff(p);
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
    
    if ~isfield(p.trialMem,'correct')
        p.trialMem.correct = 0;
    end
    if ~isfield(p.trialMem,'stairstart')
        p.trialMem.stairstart = 1; %mark transition between normal and staircase
    end

    if ~isfield(p.trialMem,'durStim')
        p.trialMem.durStim=p.trial.stimulus.durStim;
    end
    if ~isfield(p.trialMem,'offset')
        p.trialMem.offset=p.trial.stimulus.offset;
    end
    
    % set up stimulus    
    DegPerPix = p.trial.display.dWidth/p.trial.display.pWidth;
    PixPerDeg = 1/DegPerPix;
    
    %transform stimulus sizes into px
    %p.trial.stimulus.width=p.conditions{p.trial.pldaps.iTrial}.width;
    p.trial.stimulus.height=p.trial.stimulus.width;
    p.trial.stimulus.pWidth=round(p.trial.stimulus.width*PixPerDeg);
    p.trial.stimulus.pHeight=p.trial.stimulus.pWidth;
    
    
    %number of dots - density is in dots/deg^2, size in deg
    p.trial.stimulus.nrDots=round(p.trial.stimulus.dotDensity*p.trial.stimulus.width*...
        p.trial.stimulus.height);
    
    %dot size
    p.trial.stimulus.dotSizePix = round(p.trial.stimulus.dotSize*PixPerDeg);
    
    %dot displacement per frame (speed is in deg/sec)
    p.trial.stimulus.deltaF=p.trial.stimulus.dotSpeed/p.trial.stimulus.frameRate*PixPerDeg;
    
    %dot lifetime in frames (lifetime is in ms)
    p.trial.stimulus.dotLifeFr = round(p.trial.stimulus.dotLifetime*p.trial.stimulus.frameRate/1000);
    
    %dot coherence/staircase
    p.trial.stimulus.stair = p.conditions{p.trial.pldaps.iTrial}.stair;
    if p.trial.stimulus.stair ==0
        p.trialMem.stairstart=1;
        p.trialMem.dotCoherence=p.conditions{p.trial.pldaps.iTrial}.dotCoherence; %for bookkeeping
    else
        if p.trialMem.stairstart==1
            p.trialMem.dotCoherence=p.conditions{p.trial.pldaps.iTrial}.dotCoherence;
            p.trialMem.stairstart=0;
            p.trialMem.correct=0;
        else
            %caution 6/6/25
            p.trial.stimulus.dotCoherence = p.trialMem.dotCoherence;
        end
    end
    
    %direction
    p.trial.stimulus.direction = p.conditions{p.trial.pldaps.iTrial}.direction;
    
    %stimulus center
    p.trial.stimulus.centerX = p.trial.stimulus.centerX;

    %stimulus center
    p.trial.stimulus.stimSide = p.conditions{p.trial.pldaps.iTrial}.stimSide;
    offsetconv = 25*tan(deg2rad(p.trialMem.offset))*36.6;
    p.trial.stimulus.centerX = p.trial.stimulus.centerX+...
        p.trial.stimulus.stimSide*offsetconv;
    

    %initialize frame
    p.trial.stimulus.frameI = 0;
    
    %initialize dot positions - these need to be in pixels from center
    randpos=rand(2,p.trial.stimulus.nrDots); %this gives numbers between 0 and 1
    randpos(1,:)=(randpos(1,:)-0.5)*p.trial.stimulus.pWidth;
    randpos(2,:)=(randpos(2,:)-0.5)*p.trial.stimulus.pHeight;
    
    %initialize noise vector
    nrSignal=round(p.trial.stimulus.nrDots*p.trialMem.dotCoherence);
    noisevec=zeros(p.trial.stimulus.nrDots,1);
    noisevec(1:nrSignal)=1;
    
    %initialize directions: correct displacement for signal, random for noise
    %side is either 1 or 2; 1 should equal direction=0, 2 direction=180
    randdir=zeros(p.trial.stimulus.nrDots,1);
    randdir(1:end)=p.trial.stimulus.direction;
    idx=find(noisevec==0);
    randdir(idx)=randi([0,359],length(idx),1);
    
    
    %initialize lifetime vector
    if p.trial.stimulus.dotLifeFr>0
        lifetime=randi(p.trial.stimulus.dotLifeFr,p.trial.stimulus.nrDots,1);
    end
    
    %compute nr frames
    p.trial.stimulus.nrFrames=p.trialMem.durStim*p.trial.stimulus.frameRate;
    
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
                if rvec(i)<p.trialMem.dotCoherence %these get moved with the signal
                    randdir(idx(i))=p.trial.stimulus.direction;
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
        %pause(p.trialMem.durStim)
        if f == p.trial.stimulus.nrFrames
            pds.LED.stimLEDOff(p);
        end
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
    disp(['Current Stim duration:  ' num2str(p.trialMem.durStim)])
    disp(['Current Offset:  ' num2str(p.trialMem.offset) ' spatial degrees'])
    disp(['Offset max is 30 spatial degrees'])
    %show reward amount
    if p.trial.pldaps.draw.reward.show
        pds.behavior.reward.showReward(p,{'S';'L';'R';'M'})
    end
    
    %show stats
    pds.behavior.countTrial(p,p.trial.pldaps.goodtrial); %updates counters
    %update the coherence list
    idx=find(p.trialMem.stats.count.coh(:,1)==p.trialMem.dotCoherence);
    p.trialMem.stats.count.coh(idx,2)=p.trialMem.stats.count.coh(idx,2)+1;

    disp(num2str(vertcat(p.trialMem.stats.val,p.trialMem.stats.count.Ntrial,...
        p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100)))
    %disp(p.trialMem.stats.count.coh)
    
    switch p.trial.userInput
        case 1
            p.trialMem.durStim=p.trialMem.durStim+p.trial.stimulus.delta_durStim;
            disp(['increased stim duration to ' num2str(p.trialMem.durStim)])
        case 2
            p.trialMem.durStim=p.trialMem.durStim-p.trial.stimulus.delta_durStim;
            disp(['decreased stim duration to ' num2str(p.trialMem.durStim)])
        case 3
            p.trialMem.offset=p.trialMem.offset + (p.trial.stimulus.delta_offset);
            disp(['Offset increased to ' num2str(p.trialMem.offset)])
        case 4
            p.trialMem.offset=p.trialMem.offset - (p.trial.stimulus.delta_offset);
            disp(['Offset decreased to ' num2str(p.trialMem.offset)])
    end

    if p.trial.stimulus.stair == 1
        %staircase
        if p.trial.pldaps.goodtrial & p.trialMem.correct == 2
            p.trialMem.dotCoherence = p.trialMem.dotCoherence - p.trial.stimulus.step;
            if p.trialMem.dotCoherence<0
                p.trialMem.dotCoherence=0;
            end
            p.trialMem.correct = 0;
        elseif ~p.trial.pldaps.goodtrial
            p.trialMem.dotCoherence = p.trialMem.dotCoherence + p.trial.stimulus.step;
            if p.trialMem.dotCoherence>1
                p.trialMem.dotCoherence=1;
            end
            p.trialMem.correct = 0;
        end
        disp(['Coherence on the next trial: ' num2str(p.trialMem.dotCoherence)]);
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