function driftdots_trial_free(p,state)

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
            Screen(p.trial.display.ptr, 'FillRect', p.trial.display.bgColor)
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

        

        
%------------------------------------------------------------------%
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
switch p.conditions{p.trial.pldaps.iTrial}.side
    case 1
        p.trial.side=p.trial.stimulus.side.LEFT;
    case 2
        p.trial.side=p.trial.stimulus.side.RIGHT;
    case 3
        p.trial.side=p.trial.stimulus.side.MIDDLE;
end

%% set up stimulus

DegPerPix = p.trial.display.dWidth/p.trial.display.pWidth;
PixPerDeg = 1/DegPerPix;

%number of Dots
%p.trial.stimulus.nrDots = p.conditions{p.trial.pldaps.iTrial}.nrDots;
%dot size
p.trial.stimulus.dotSizePix = round(p.trial.stimulus.dotSize*PixPerDeg);
%dot coherence
%p.trial.stimulus.dotCoherence = p.conditions{p.trial.pldaps.iTrial}.dotCoherence;
%dot speed
p.trial.stimulus.dotSpeed = p.conditions{p.trial.pldaps.iTrial}.dotSpeed;
%direction
p.trial.stimulus.direction = p.conditions{p.trial.pldaps.iTrial}.direction;
%lifetime
%p.trial.stimulus.dotLifetime = p.conditions{p.trial.pldaps.iTrial}.dotLifetime;
%initialize frame
p.trial.stimulus.frameI = 0;

%initialize dot positions - these need to be in pixels from center
% randpos=rand(2,p.trial.stimulus.nrDots); %this gives numbers between 0 and 1
% randpos(1,:)=(randpos(1,:)-0.5)*p.trial.display.pWidth; 
% randpos(2,:)=(randpos(2,:)-0.5)*p.trial.display.pHeight;

spacing = p.trial.display.pWidth/p.trial.stimulus.columnspacing;
[xpos, ypos] = meshgrid([(-p.trial.display.pWidth/2) + 1:spacing:p.trial.display.pWidth/2], [(-p.trial.display.pHeight/2)+1:108:(p.trial.display.pHeight/2)+20]);
the_color = repmat([repmat([0,0,0],11,1); repmat([255,255,255], 11,1)], (p.trial.stimulus.columnspacing / 2), 1);
xpos = xpos(:);
ypos = ypos(:);
randpos(1, :) = xpos;
randpos(2, :) = ypos; 



%pick color for each dot
p.trial.stimulus.dotcolor=the_color';


%initialize noise vector


%initialize directions: correct displacement for signal, random for noise
%side is either 1 or 2; 1 should equal direction=0, 2 direction=180
randdir=zeros(p.trial.stimulus.nrDots,1);
randdir(1:end)=p.trial.stimulus.direction;



%initialize lifetime vector

%compute nr frames
p.trial.stimulus.nrFrames=p.trial.stimulus.durStim*p.trial.stimulus.frameRate;

%compute speed
deltaF=p.trial.stimulus.dotSpeed*PixPerDeg;

%save misc variables
p.trial.stimulus.randpos = randpos;
p.trial.stimulus.randdir = randdir;
p.trial.stimulus.deltaF = deltaF;


%%
%set state
p.trial.state=p.trial.stimulus.states.START;
if p.trial.camera.use;
    pds.behavcam.startcam(p);
end

%------------------------------------------------------------------%
%show stimulus - handles rotation and movement of grating
function showStimulus(p)
        p.trial.stimulus.frameI=p.trial.stimulus.frameI+1;
        if p.trial.stimulus.frameI<=p.trial.stimulus.nrFrames
            f = p.trial.stimulus.frameI;
            randpos = p.trial.stimulus.randpos;
            randdir = p.trial.stimulus.randdir;
    
            % set up stimulus
            DegPerPix = p.trial.display.dWidth/p.trial.display.pWidth;
            PixPerDeg = 1/DegPerPix;

            %fixed parameters
            %dot size
            p.trial.stimulus.dotSizePix = round(p.trial.stimulus.dotSize*PixPerDeg);
            p.trial.stimulus.stimRadiusPix= round(p.trial.stimulus.stimRadius*PixPerDeg);
            stimRadius=p.trial.stimulus.stimRadiusPix;
            
            if p.trial.stimulus.direction == 0
                randpos(1,:) = randpos(1,:) - p.trial.stimulus.driftSpeed*192;
                theidx = find(randpos(1,:) < -959);
                randpos(1,theidx) = randpos(1, theidx) + 1920;

            else
               randpos(1,:) = randpos(1,:) + p.trial.stimulus.driftSpeed*192;
               theidx = find(randpos(1,:) > 960);
               randpos(1,theidx) = randpos(1, theidx) - 1920;

            end
            newcolor = p.trial.stimulus.dotcolor;
            
            if p.trial.stimulus.aperture == 1
                %[~, rad] = cart2pol(randpos(1, :), randpos(2, :));
                %x = randpos(1,:);
                %y = randpos(2,:);
                %newx = x(rad<stimRadius);
                %newy = y(rad<stimRadius);
                %coloridx = find(rad<stimRadius);
                %newcolor = p.trial.stimulus.dotcolor(:, coloridx);
                %filtered = [newx; newy];
                idx=abs(randpos(1,:))<stimRadius & abs(randpos(2,:))<stimRadius;
                
                %p.trial.stimulus.filtered{f}=filtered;
                %Screen('DrawDots', p.trial.display.ptr, p.trial.stimulus.filtered{p.trial.stimulus.frameI}, ...
                Screen('DrawDots', p.trial.display.ptr, randpos(:,idx),...
                p.trial.stimulus.dotSizePix, newcolor(:,idx),...%newcolor, ...
                [p.trial.display.pWidth/2 p.trial.display.pHeight/2],1);
                
                
                p.trial.stimulus.dotpos{f}=randpos;
                p.trial.stimulus.randpos = randpos;
                p.trial.stimulus.randdir = randdir;
            else
                p.trial.stimulus.dotpos{f}=randpos;
                p.trial.stimulus.randpos = randpos;
                p.trial.stimulus.randdir = randdir;
                Screen('DrawDots', p.trial.display.ptr, p.trial.stimulus.dotpos{p.trial.stimulus.frameI}, ...
                    p.trial.stimulus.dotSizePix, newcolor, ...
                    [p.trial.display.pWidth/2 p.trial.display.pHeight/2],1);
            end
        end

%------------------------------------------------------------------%
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