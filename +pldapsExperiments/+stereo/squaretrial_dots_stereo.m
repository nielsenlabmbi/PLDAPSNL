function squaretrial_dots_stereo(p,state)
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
     
        if p.trial.state==p.trial.stimulus.states.STIMON
            Screen('DrawDots', p.trial.display.ptr, p.trial.stimulus.dotposR, ...
                p.trial.stimulus.dotSizePix, p.trial.stimulus.dotColorR, ...
                [p.trial.stimulus.centerX p.trial.stimulus.centerY],1);

            Screen('DrawDots', p.trial.display.ptr, p.trial.stimulus.dotposL, ...
                p.trial.stimulus.dotSizePix, p.trial.stimulus.dotColorL, ...
                [p.trial.stimulus.centerX p.trial.stimulus.centerY],1);
              Screen('DrawDots', p.trial.display.ptr, p.trial.stimulus.dotposB, ...
                            p.trial.stimulus.dotSizePix, p.trial.stimulus.dotColorR, ...
                            [p.trial.stimulus.centerX p.trial.stimulus.centerY],1)
               Screen('DrawDots', p.trial.display.ptr, p.trial.stimulus.dotposB, ...
                            p.trial.stimulus.dotSizePix, p.trial.stimulus.dotColorL, ...
                            [p.trial.stimulus.centerX p.trial.stimulus.centerY],1)
        else
            Screen(p.trial.display.ptr, 'FillRect', 0.5);
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
            p.trial.stimulus.midpointCrossed = 1;
            p.trial.stimulus.timeTrialCross = p.trial.ttime;
            p.trial.stimulus.frameTrialCross = p.trial.iFrame;
            pds.LED.stimLEDOn(p);
        end    

    case p.trial.stimulus.states.STIMON %stimulus shown; port selected in response
       %timing would go here

        %check ports
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

%stimulus orientation (one per side)
sideResp=p.conditions{p.trial.pldaps.iTrial}.side;
p.trial.stimulus.ori = p.trial.stimulus.angle(sideResp);


%color - determined by condition
%map: 
%condIdx 1, 2, 7, 8 - both eyes one color, crossed with side (double
%to increase frequency)
%condIdx 3, 4, 9, 10 - both eyes other color
%condIdx 5, 11: L color 1, R color 2, crossed with side
%condIdx 6, 12: L color 2, R color 1, crossed with side

condIdx=p.conditions{p.trial.pldaps.iTrial}.condIdx;

switch mod(condIdx-1,6)+1
    case {1,2} %monocular, both eyes color 1
        p.trial.stimulus.dotColorR=p.trial.stimulus.dotColor1;
        p.trial.stimulus.dotColorL=p.trial.stimulus.dotColor1;
        bino=0;
    case {3,4} %monocular, both eyes color 2
        p.trial.stimulus.dotColorR=p.trial.stimulus.dotColor2;
        p.trial.stimulus.dotColorL=p.trial.stimulus.dotColor2;
        bino=0;
    case 5 %monocular 1
        p.trial.stimulus.dotColorL=p.trial.stimulus.dotColor1;
        p.trial.stimulus.dotColorR=p.trial.stimulus.dotColor2;
        bino=1;
    case 6 %monocular 2
        p.trial.stimulus.dotColorL=p.trial.stimulus.dotColor1;
        p.trial.stimulus.dotColorR=p.trial.stimulus.dotColor2;
        bino=1;
end

%disp(p.trial.stimulus.dotColorR)


%figure out dots
DegPerPix = p.trial.display.dWidth/p.trial.display.pWidth;
PixPerDeg = 1/DegPerPix;

p.trial.stimulus.centerX= 990; %pixels
p.trial.stimulus.centerY= 510; %500 puts in center, 810 is bottom
%number of dots - density is in dots/deg^2, size in deg
p.trial.stimulus.nrDots=round(p.trial.stimulus.dotDensity*p.trial.stimulus.sizeX*...
    p.trial.stimulus.sizeY);

%dot size
p.trial.stimulus.dotSizePix = round(p.trial.stimulus.dotSize*PixPerDeg);
p.trial.stimulus.dispPix=round(p.trial.stimulus.disp*PixPerDeg);

p.trial.stimulus.nrDots=round(p.trial.stimulus.dotDensity*p.trial.stimulus.sizeX*...
    p.trial.stimulus.sizeY);
randpos=rand(2,p.trial.stimulus.nrDots); %this gives numbers between 0 and 1
if p.trial.stimulus.ori==1
 randpos(1,:)=(randpos(1,:)-0.5)*p.trial.stimulus.sizeX;
 randpos(2,:)=(randpos(2,:)-0.5)*p.trial.stimulus.sizeY;
 else
     randpos(1,:)=(randpos(1,:)-0.5)*p.trial.stimulus.sizeY;
 randpos(2,:)=(randpos(2,:)-0.5)*p.trial.stimulus.sizeX;
 end
randposL=randpos;
randposR=randpos;
if bino==1;
    randposR(1,:)=randposR(1,:)+p.trial.stimulus.dispPix; 
end
p.trial.stimulus.dotposL =randposL;
p.trial.stimulus.dotposR=randposR;
%background dots- less dense than stim 
p.trial.stimulus.nrDotsB=round(p.trial.stimulus.dotDensity*.8*p.trial.stimulus.sizeX*...
    p.trial.stimulus.sizeY);
randposB=rand(2,p.trial.stimulus.nrDotsB); %this gives numbers between 0 and 1
 if p.trial.stimulus.ori==1
 randposB(1,:)=(randposB(1,:)-0.5)*2000;
 randposB(2,:)=(randposB(2,:)-0.5)*1000;
 randposB=randposB(:,randposB(1,:)<-.5*p.trial.stimulus.sizeX|randposB(1,:)>.5*p.trial.stimulus.sizeX|...
     randposB(2,:)<-.5*p.trial.stimulus.sizeY|randposB(2,:)>.5*p.trial.stimulus.sizeY);

 else
 randposB(1,:)=(randposB(1,:)-0.5)*2000;
 randposB(2,:)=(randposB(2,:)-0.5)*1000;
 randposB=randposB(:,randposB(2,:)<-.5*p.trial.stimulus.sizeX|randposB(2,:)>.5*p.trial.stimulus.sizeX|...
     randposB(1,:)<-.5*p.trial.stimulus.sizeY|randposB(1,:)>.5*p.trial.stimulus.sizeY);
 end
 p.trial.stimulus.dotposB =randposB;
% if p.trial.stimulus.ori==1
%     randpos(1,:)=(randpos(1,:)-0.5)*2000;
%     randpos(2,:)=(randpos(2,:)-0.5)*1000;
%     randposind=(randpos(1,:)>-.5*p.trial.stimulus.sizeX & randpos(1,:)<.5*p.trial.stimulus.sizeX &...
%         randpos(2,:)>-.5*p.trial.stimulus.sizeY & randpos(2,:)<.5*p.trial.stimulus.sizeY);
% 
% else
%     randpos(1,:)=(randpos(1,:)-0.5)*2000;
%     randpos(2,:)=(randpos(2,:)-0.5)*1000;
%     randposind=(randpos(2,:)>-.5*p.trial.stimulus.sizeX & randpos(2,:)<.5*p.trial.stimulus.sizeX &...
%         randpos(1,:)>-.5*p.trial.stimulus.sizeY & randpos(1,:)<.5*p.trial.stimulus.sizeY);
% end
% randposL=randpos;
% randposR=randpos;
% randposR(1,randposind)=randpos(1,randposind)+p.trial.stimulus.dispPix;
% p.trial.stimulus.dotposL =randposL;
% p.trial.stimulus.dotposR=randposR;


%set state
p.trial.state=p.trial.stimulus.states.START;
if p.trial.stimulus.midpointIR
    p.trial.stimulus.midpointCrossed = 0;
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
 pds.behavior.countTrialNew(p,p.trial.pldaps.goodtrial,1,1); %updates counters
 pds.behavior.printCounter(p.trialMem.stats.sideCounter,p.trialMem.stats.sideCounterNames)
 pds.behavior.printCounter(p.trialMem.stats.condCounter{1},p.trialMem.stats.condCounterNames{1})


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
end