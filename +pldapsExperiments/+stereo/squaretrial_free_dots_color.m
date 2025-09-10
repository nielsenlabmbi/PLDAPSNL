function squaretrial_free_dots_color(p,state)
%%%% Note: includes staircase functionality for spatial frequency. Set
%%%% stimulus.step = 0 in settings file to suppress staircase. 

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
        elseif p.trial.state==p.trial.stimulus.states.STIMON || p.trial.state==p.trial.stimulus.states.INCORRECT
            if p.trial.stimulus.midpointIR
                if p.trial.stimulus.stimOff
                    Screen(p.trial.display.ptr, 'FillRect', 0.5)
                else
                    %Screen('FillPoly',p.trial.display.ptr,[0 0 0],p.trial.stimulus.rectCoord);
                    Screen('DrawDots', p.trial.display.ptr, p.trial.stimulus.dotposR, ...
                        p.trial.stimulus.dotSizePix, p.trial.stimulus.dotColorR, ...
                        [p.trial.stimulus.centerX p.trial.stimulus.centerY],1);

                    Screen('DrawDots', p.trial.display.ptr, p.trial.stimulus.dotposL, ...
                        p.trial.stimulus.dotSizePix, p.trial.stimulus.dotColorL, ...
                        [p.trial.stimulus.centerX p.trial.stimulus.centerY],1);
                end

            else
                %Screen('FillPoly',p.trial.display.ptr,[0 0 0],p.trial.stimulus.rectCoord);
                Screen('DrawDots', p.trial.display.ptr, p.trial.stimulus.dotposR, ...
                    p.trial.stimulus.dotSizePix, p.trial.stimulus.dotColorR, ...
                    [p.trial.stimulus.centerX p.trial.stimulus.centerY],1);

                Screen('DrawDots', p.trial.display.ptr, p.trial.stimulus.dotposL, ...
                    p.trial.stimulus.dotSizePix, p.trial.stimulus.dotColorL, ...
                    [p.trial.stimulus.centerX p.trial.stimulus.centerY],1);

            end

        end


    case p.trial.pldaps.trialStates.trialCleanUpandSave
        cleanUpandSave(p);

end

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
            %p.trial.state=p.trial.stimulus.states.STIMON;%add info for
            %midline crossing 6/8/25
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
        %check whether any port chosen
        if p.trial.stimulus.midpointIR
            if activePort==p.trial.stimulus.port.MIDDLE
                p.trial.stimulus.midpointCrossed = 1;
                p.trial.stimulus.timeTrialCross = p.trial.ttime;
                p.trial.stimulus.frameTrialCross = p.trial.iFrame;
            end
            if p.trial.stimulus.midpointCrossed & ...
                    p.trial.ttime > p.trial.stimulus.timeTrialCross + p.trial.stimulus.offStim
                p.trial.stimulus.stimOff = 1;
                p.trial.stimulus.timeOff = p.trial.ttime;
                p.trial.stimulus.frameOff = p.trial.iFrame;
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
end
        

        
%% ------------------------------------------------------------------%
%setup trial parameters, prep stimulus as far as possible
function p=trialSetup(p)



%get side for condition
if p.conditions{p.trial.pldaps.iTrial}.side==2
    p.trial.side=p.trial.stimulus.side.LEFT;
else
    p.trial.side=p.trial.stimulus.side.RIGHT;
end


if ~isfield(p.trialMem,'offStim') %only runs at start
    p.trialMem.offStim=p.trial.stimulus.offStim;
end


p.trial.stimulus.offStim = p.trialMem.offStim;



p.trial.stimulus.ori = p.conditions{p.trial.pldaps.iTrial}.angle;
% 
% rectCoord=[-1 1
%     1 1
%     1 -1
%     -1 -1];
% if p.trial.stimulus.ori==1
%     rectCoord(:,1)=rectCoord(:,1)*p.trial.stimulus.sizeX/2;
%     rectCoord(:,2)=rectCoord(:,2)*p.trial.stimulus.sizeY/2;
% else
%     rectCoord(:,1)=rectCoord(:,1)*p.trial.stimulus.sizeY/2;
%     rectCoord(:,2)=rectCoord(:,2)*p.trial.stimulus.sizeX/2;
% end
% rectCoord(:,1)=rectCoord(:,1)+p.trial.display.pWidth/2;
% rectCoord(:,2)=rectCoord(:,2)+p.trial.display.pHeight/2;
% 
% p.trial.stimulus.rectCoord=rectCoord;


% set up stimulus

if ~isfield(p.trialMem,'dotSize') %only runs at start
    p.trialMem.dotSize=p.trial.stimulus.dotSize;
end
if ~isfield(p.trialMem,'dotDensity') %only runs at start
    p.trialMem.dotDensity=p.trial.stimulus.dotDensity;
end
if ~isfield(p.trialMem, 'backgroundDot')
    p.trialMem.backgroundDot=p.trial.stimulus.backgroundDot;
end


DegPerPix = p.trial.display.dWidth/p.trial.display.pWidth;
PixPerDeg = 1/DegPerPix;

p.trial.stimulus.dotSize = p.trialMem.dotSize; %.5;% original 1.5
p.trial.stimulus.dotDensity =p.trialMem.dotDensity; %0.005; %dots/deg^2
p.trial.stimulus.backgroundDot=p.trialMem.backgroundDot;
p.trial.stimulus.dotColorR = [1 0 0];
p.trial.stimulus.dotColorL= [0 0 .7];
p.trial.stimulus.centerX= 990; %pixels
p.trial.stimulus.centerY= 510; %500 puts in center, 810 is bottom
%number of dots - density is in dots/deg^2, size in deg
p.trial.stimulus.nrDots=round(p.trial.stimulus.dotDensity*p.trial.stimulus.sizeX*...
    p.trial.stimulus.sizeY);

%dot size
p.trial.stimulus.dotSizePix = round(p.trial.stimulus.dotSize*PixPerDeg);
p.trial.stimulus.dispPix=round(p.trial.stimulus.disp*PixPerDeg);
 %initialize dot positions - these need to be in pixels from center
 %old section makes dots just for center rectangle
%  randpos=rand(2,p.trial.stimulus.nrDots); %this gives numbers between 0 and 1
%  if p.trial.stimulus.ori==1
%  randpos(1,:)=(randpos(1,:)-0.5)*p.trial.stimulus.sizeX;
%  randpos(2,:)=(randpos(2,:)-0.5)*p.trial.stimulus.sizeY;
%  else
%      randpos(1,:)=(randpos(1,:)-0.5)*p.trial.stimulus.sizeY;
%  randpos(2,:)=(randpos(2,:)-0.5)*p.trial.stimulus.sizeX;
%  end
% p.trial.stimulus.dotpos =randpos;

%if p.trial.stimulus.backgroundDot
p.trial.stimulus.nrDots=round(p.trial.stimulus.dotDensity*p.trial.stimulus.sizeX*...
    p.trial.stimulus.sizeY);
randpos=rand(2,p.trial.stimulus.nrDots); %this gives numbers between 0 and 1
 if p.trial.stimulus.ori==1
 randpos(1,:)=(randpos(1,:)-0.5)*2000;
 randpos(2,:)=(randpos(2,:)-0.5)*1000;
 randposind=(randpos(1,:)>-.5*p.trial.stimulus.sizeX&randpos(1,:)<.5*p.trial.stimulus.sizeX&...
     randpos(2,:)>-.5*p.trial.stimulus.sizeY&randpos(2,:)<.5*p.trial.stimulus.sizeY);

 else
 randpos(1,:)=(randpos(1,:)-0.5)*2000;
 randpos(2,:)=(randpos(2,:)-0.5)*1000;
 randposind=(randpos(2,:)>-.5*p.trial.stimulus.sizeX&randpos(2,:)<.5*p.trial.stimulus.sizeX&...
     randpos(1,:)>-.5*p.trial.stimulus.sizeY&randpos(1,:)<.5*p.trial.stimulus.sizeY);
 end
 randposL=randpos;
 randposR=randpos;
 randposR(1,randposind)=randpos(1,randposind)+p.trial.stimulus.dispPix; 
 p.trial.stimulus.dotposL =randposL;
 p.trial.stimulus.dotposR=randposR;





%set state
p.trial.state=p.trial.stimulus.states.START;
if p.trial.stimulus.midpointIR
    p.trial.stimulus.midpointCrossed = 0;
    p.trial.stimulus.stimOff=0;
end
if p.trial.camera.use
    pds.behavcam.startcam(p);
end

end


%% ------------------------------------------------------------------%
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
    round(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100,1)))

%change stimulus duration if needed
switch p.trial.userInput
    case 1
%         p.trialMem.dotSize=p.trialMem.dotSize-p.trial.stimulus.stepSize;
%         disp(['decreased dot size to ' num2str(p.trialMem.dotSize)])
p.trialMem.backgroundDot=0;
disp(['background dots off'])
    case 2
%         p.trialMem.dotSize=p.trialMem.dotSize+p.trial.stimulus.stepSize;
%         disp(['increased dot size to ' num2str(p.trialMem.dotSize)])
p.trialMem.backgroundDot=1;
disp(['background dots on'])
    case 3
        p.trialMem.dotDensity=p.trialMem.dotDensity+p.trial.stimulus.stepDens;
        disp(['increased dot dens to ' num2str(p.trialMem.dotDensity)])
    case 4
        p.trialMem.dotDensity=p.trialMem.dotDensity-p.trial.stimulus.stepDens;
        disp(['decreased dot dens to ' num2str(p.trialMem.dotDensity)])
end
end


% %show stats
% pds.behavior.countTrial(p,p.trial.pldaps.goodtrial);
% disp(['C: ' num2str(p.trialMem.stats.val)])
% disp(['N: ' num2str(p.trialMem.stats.count.Ntrial)])
% disp(['P: ' num2str(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100)])
    

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
end