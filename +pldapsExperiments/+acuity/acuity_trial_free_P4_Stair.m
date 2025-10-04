function acuity_trial_free_P4_Stair(p,state)

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
            Screen(p.trial.display.ptr, 'FillRect', 0.5)
        elseif p.trial.state==p.trial.stimulus.states.STIMON 
            if p.trial.stimulus.midpointIR==1 && p.trial.stimulus.midpointCrossed == 1          
                Screen(p.trial.display.ptr, 'FillRect', 0.5)
            else
                Screen('DrawTexture',p.trial.display.ptr,p.trial.gratTex,[],p.trial.gratPos,0);
            end
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
                pds.behavcam.triggercam(p,1); %GENERAL
                %pds.behavcam.triggerFLIR(p,1); %for use with BLACKFLY-S
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
        if p.trial.stimulus.midpointIR
            if activePort==p.trial.stimulus.port.MIDDLE
                p.trial.stimulus.midpointCrossed = 1;
                p.trial.stimulus.timeTrialCross = p.trial.ttime;
                p.trial.stimulus.frameTrialCross = p.trial.iFrame;
            end
          
        end
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
            
            p.trialMem.correct = p.trialMem.correct + 1;
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

        

        
%% ------------------------------------------------------------------%
%setup trial parameters, prep stimulus as far as possible
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
if p.conditions{p.trial.pldaps.iTrial}.side==2
    p.trial.side=p.trial.stimulus.side.LEFT;
else
    p.trial.side=p.trial.stimulus.side.RIGHT;
end

%staircase performance counters - only happens at start of script
if ~isfield(p.trialMem,'correct')
    p.trialMem.correct = 0;
end

%staircase state - only happens at start of script
if ~isfield(p.trialMem,'stair')
    p.trialMem.stair = p.trial.stimulus.stair;
end

%contrast values - only happens at start of script
if ~isfield(p.trialMem,'contrast')
    p.trialMem.contrast = p.trial.stimulus.contrastDefault;
end

p.trial.stimulus.range = p.trialMem.contrast;
%execute staircase based on stimulus side
%staircase left
if p.trialMem.stair==0 %staircase off; default value
    %we can do it this way since resetting the staircase state resets the staircase anyways
    p.trialMem.contrast=p.trial.stimulus.contrastDefault;
    p.trialMem.stairstart=1;
else
    if p.trialMem.stairstart==1 %staircase is being initialized
        p.trialMem.contrast=p.trial.stimulus.range;
        p.trialMem.stairstart=0;
        p.trialMem.correct=0;
    end
end
p.trial.stimulus.range = p.trialMem.contrast;



p.trial.stimulus.sf = p.trial.stimulus.sf;
p.trial.stimulus.angle = p.conditions{p.trial.pldaps.iTrial}.angle;
p.trial.stimulus.phase = mod(180, (rand < 0.5)*180 + 180); % phase is random 0 or 180
%p.trial.stimulus.range = p.conditions{p.trial.pldaps.iTrial}.range;
p.trial.stimulus.fullField = p.trial.stimulus.fullField;

%make grating
%DegPerPix = p.trial.display.dWidth/p.trial.display.pWidth;
%PixPerDeg = 1/DegPerPix;

ApertureDeg = 2*p.trial.stimulus.radius;%DegPerCyc*nCycles;

% CREATE A MESHGRID THE SIZE OF THE GRATING
x=linspace(-(p.trial.display.dWidth/2),p.trial.display.dWidth/2,p.trial.display.pWidth);%-p.trial.stimulus.shift(p.trial.side);
y=linspace(-(p.trial.display.dHeight/2),p.trial.display.dHeight/2,p.trial.display.pHeight);
[x,y] = meshgrid(x,y);

% Transform to account for orientation
% note: transformation changed from headfixed
sdom=x*sin(p.trial.stimulus.angle*pi/180)-y*cos(p.trial.stimulus.angle*pi/180);

% GRATING
sdom=sdom*p.trial.stimulus.sf*2*pi;
sdom1=cos(sdom-p.trial.stimulus.phase*pi/180);

%square wave
%sdom1=sign(sdom1);

if isfield(p.trial.stimulus,'fullField') && p.trial.stimulus.fullField == 1
    grating = sdom1;
else
    % CREATE A GAUSSIAN TO SMOOTH THE OUTER 10% OF THE GRATING
    r = sqrt(x.^2 + y.^2);
    sigmaDeg = ApertureDeg/16.5;
    MaskLimit=.6*ApertureDeg/2;
    maskdom = exp(-.5*(r-MaskLimit).^2/sigmaDeg.^2);
    maskdom(r<MaskLimit) = 1;
    grating = sdom1.*maskdom;
end

% TRANSFER THE GRATING INTO AN IMAGE
grating = round(grating*p.trial.stimulus.range) + 127;

p.trial.gratTex = Screen('MakeTexture',p.trial.display.ptr,grating);
p.trial.gratPos = [0 0 1920 1080];


%set state
p.trial.state=p.trial.stimulus.states.START;
if p.trial.stimulus.midpointIR
    p.trial.stimulus.midpointCrossed = 0;
end
if p.trial.camera.use
    pds.behavcam.startcam(p);
end



%% ------------------------------------------------------------------%
%display stats at end of trial
function cleanUpandSave(p)
%stop camera and set trigger to low
pds.behavcam.stopcam(p);
pds.behavcam.triggercam(p,0);

disp('----------------------------------')
disp(['Trialno: ' num2str(p.trial.pldaps.iTrial)])
disp(['Current Contrast:  ' num2str(p.trialMem.contrast)])
%show reward amount
if p.trial.pldaps.draw.reward.show
    pds.behavior.reward.showReward(p,{'S';'L';'R'})
end

%show stats
pds.behavior.countTrial(p,p.trial.pldaps.goodtrial);
num2str(vertcat(p.trialMem.stats.val,p.trialMem.stats.count.Ntrial,...
    round(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100,1)))

pds.behavior.countTrialSide(p,p.trial.pldaps.goodtrial);
disp(['NrL: ' num2str(p.trialMem.stats.count.Nleft) ' NrR: ' num2str(p.trialMem.stats.count.Nright)])
disp(['CorrL: ' num2str(p.trialMem.stats.count.NleftCorr) ' CorrR: ' num2str(p.trialMem.stats.count.NrightCorr)])
disp(['PercL: ' num2str(p.trialMem.stats.count.NleftCorr/p.trialMem.stats.count.Nleft) ...
    ' PercR: ' num2str(p.trialMem.stats.count.NrightCorr/p.trialMem.stats.count.Nright)])

if p.trialMem.stair == 1
    %staircase
    if p.trial.pldaps.goodtrial & p.trialMem.correct == 2 %decrease coherence after 2 correct trials
        p.trialMem.contrast = p.trialMem.contrast - p.trial.stimulus.delta_contrast;
        if p.trialMem.contrast<0
            p.trialMem.contrast=7;
        end
        p.trialMem.correct = 0; %reset counter
    elseif ~p.trial.pldaps.goodtrial %immediately increase after incorrect trial
        p.trialMem.contrast = p.trialMem.contrast + p.trial.stimulus.delta_contrast;
        if p.trialMem.contrast>127
            p.trialMem.contrast=127;
        end
        p.trialMem.correct = 0;
    end
    disp(['Coh on the nexttrial: ' num2str(p.trialMem.contrast)]);
end

switch p.trial.userInput
    case 1 %left key - left staircase on/off
        p.trialMem.stair=~p.trialMem.stair;
        disp(['changed staircase state to ' num2str(p.trialMem.stair)])
end

%% -------------------------------------------------------------------%
%%%%%%Helper functions
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