sefunction oflowtrial_free(p,state)

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


 

%% -------------------------------------------------------------------%
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
        if p.trial.stimulus.forceCorrect == 1 %must give correct response before ending trial            
            %check whether any port chosen
            if ismember(activePort, [p.trial.stimulus.port.MIDDLE p.trial.stimulus.port.LEFT p.trial.stimulus.port.RIGHT])
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

%we are implementing the graziano style (spiral space) optic flow pattern
%here, with noise that is random in direction, but not speed (each dot
%keeps its speed and direction throughout its lifetime)

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

% set up stimulus
DegPerPix = p.trial.display.dWidth/p.trial.display.pWidth;
PixPerDeg = 1/DegPerPix;

%fixed parameters
%dot size
p.trial.stimulus.dotSizePix = round(p.trial.stimulus.dotSize*PixPerDeg);
p.trial.stimulus.stimRadiusPix= round(p.trial.stimulus.stimRadius*PixPerDeg);
stimRadius=p.trial.stimulus.stimRadiusPix;

%displacements: set so that the scaling factor makes the average speed
%appear at half the stimulus radius
avgDeltaFrame = p.trial.stimulus.dotSpeed*PixPerDeg;
speedScale = 2*avgDeltaFrame/p.trial.stimulus.stimRadiusPix; 

%compute nr frames
p.trial.stimulus.nrFrames=p.trial.stimulus.durStim*p.trial.stimulus.frameRate;


%trial dependent parameters
%dot coherence 
p.trial.stimulus.dotCoherence = p.conditions{p.trial.pldaps.iTrial}.dotCoherence;
%direction
p.trial.stimulus.direction = p.conditions{p.trial.pldaps.iTrial}.direction;


%initialize dot positions
rvec=rand(2,p.trial.stimulus.nrDots); %gives numbers between 0 and 1
xypos(1,:)=(rvec(1,:)-0.5)*2*p.trial.stimulus.stimRadiusPix;
xypos(2,:)=(rvec(2,:)-0.5)*2*p.trial.stimulus.stimRadiusPix;

%set initial directions for all dots
[th,rad]=cart2pol(xypos(1,:),xypos(2,:));
dotDir=th+pi; %this is in radians
deltaFrame=speedScale*rad;

%change directions for noise dots (we can grab the first N dots here since
%position is random)
nrNoise=round(p.trial.stimulus.nrDots*(1-p.trial.stimulus.dotCoherence));
if nrNoise>0
    dotDir(1:nrNoise)=randi([0,359],nrNoise,1);
end

%initialize lifetime vector
lifetime=randi(p.trial.stimulus.dotLifetime,p.trial.stimulus.nrDots,1);


%we need to precompute the dot sequence here - to equate dot densities
%across expanding and contracting stimuli, the contracting stimulus is an
%expanding stimulus played in reverse (otherwise the density at the center
%ends up being higher and makes the stimulus easier than the other one)
%180 deg = expansion

for f=1:p.trial.stimulus.nrFrames
   
    %compute new positions and directions for any dot with lifetime
    %0
    idx=find(lifetime==0);
    
    %first move these dots to a new position
    rvec=rand(2, length(idx)); %gives numbers between 0 and 1
    xypos(1,idx)=(rvec(1,:)-0.5)*2*stimRadius;
    xypos(2,idx)=(rvec(2,:)-0.5)*2*stimRadius;
    
    %new direction and speed
    [th,rad]=cart2pol(xypos(1,idx),xypos(2,idx));
    dotDir(idx)=th+pi; %this is in radians
    deltaFrame(idx)=speedScale*rad;
    
    %make some of those new dots noise dots
    rvec=rand(1,length(idx));
    for i=1:length(idx)
        if rvec(i)>=p.trial.stimulus.dotCoherence
            dotDir(idx(i))=randi([0,359],1,1);
        end
    end
      
    %now move everyone
    xypos(1,:)=xypos(1,:)-deltaFrame.*cos(dotDir);
    xypos(2,:)=xypos(2,:)-deltaFrame.*sin(dotDir);
    
    
    %randomly reshuffle the ones that end up outside the stimulus, reset
    %lifetime direction etc according to noise level
    idxOut=find(abs(xypos(1,:))>stimRadius | abs(xypos(2,:))>stimRadius);
    rvec=rand(2, length(idxOut));
    xypos(1,idxOut)=(rvec(1,:)-0.5)*2*stimRadius;
    xypos(2,idxOut)=(rvec(2,:)-0.5)*2*stimRadius;
    
    %first set everyone as if signal
    [th,rad]=cart2pol(xypos(1,idxOut),xypos(2,idxOut));
    dotDir(idxOut)=th+pi; %this is in radians
    deltaFrame(idxOut)=speedScale*rad;
    
    %then reset direction for noise
    rvec=rand(1,length(idxOut));
    for i=1:length(idxOut)
       if rvec(i)>=p.trial.stimulus.dotCoherence
           dotDir(idxOut(i))=randi([0,359],1,1);
        end
    end
    %set lifetime to 0 so that it will be set to full next    
    lifetime(idxOut)=0;

    
    %reduce lifetime
    lifetime(lifetime==0)=p.trial.stimulus.dotLifetime;
    lifetime=lifetime-1;
 

    %remove stimulus out of radius
    [~,rad]=cart2pol(xypos(1,:),xypos(2,:));
    
    
    %save dot positions
    if p.trial.stimulus.direction==180
        p.trial.stimulus.dotpos{f}=xypos(:,rad<stimRadius);
    elseif p.trial.stimulus.direction==0
        p.trial.stimulus.dotpos{p.trial.stimulus.nrFrames-f+1}=xypos(:,rad<stimRadius);
    end
    
   
end


%save misc variables
p.trial.stimulus.deltaFrame = deltaFrame;
p.trial.stimulus.lifetime = lifetime;
p.trial.stimulus.speedScale = speedScale;

%initialize frame
p.trial.stimulus.frameI = 0;

%set state
p.trial.state=p.trial.stimulus.states.START;
if p.trial.camera.use;
    pds.behavcam.startcam(p);
end

%% ------------------------------------------------------------------%
%show stimulus - handles actual dot displacement
function showStimulus(p)
p.trial.stimulus.frameI=p.trial.stimulus.frameI+1;
if p.trial.stimulus.frameI<=p.trial.stimulus.nrFrames    
    Screen('DrawDots', p.trial.display.ptr, p.trial.stimulus.dotpos{p.trial.stimulus.frameI}, ...
        p.trial.stimulus.dotSizePix, [1 1 1], ...
        [p.trial.display.pWidth/2 p.trial.display.pHeight/2],1);
else
    Screen('DrawDots', p.trial.display.ptr, p.trial.stimulus.dotpos{p.trial.stimulus.nrFrames}, ...
        p.trial.stimulus.dotSizePix, [1 1 1], ...
        [p.trial.display.pWidth/2 p.trial.display.pHeight/2],1);
end

%% ------------------------------------------------------------------%
%display stats at end of trial
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
num2str(vertcat(p.trialMem.stats.val,p.trialMem.stats.count.Ntrial,...
    p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100))

% %show stats
% pds.behavior.countTrial(p,p.trial.pldaps.goodtrial);
% disp(['C: ' num2str(p.trialMem.stats.val)])
% disp(['N: ' num2str(p.trialMem.stats.count.Ntrial)])
% disp(['P: ' num2str(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100)])

%user function test
if p.trial.userInput==1
    disp('decrement offset:')
    p.trialMem.stimulus.offset=p.trialMem.stimulus.offset+p.trial.stimulus.deltaOffset;
    disp(['offset left - ' num2str(p.trialMem.stimulus.offset(1))]);
end
if p.trial.userInput==2
    disp('increment offset:')
    p.trialMem.stimulus.offset=p.trialMem.stimulus.offset-p.trial.stimulus.deltaOffset;
    disp(['offset left - ' num2str(p.trialMem.stimulus.offset(1))]);
end
    

%%%%%%Helper functions
%% -------------------------------------------------------------------%
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