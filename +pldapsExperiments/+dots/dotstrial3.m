function dotstrial3(p,state)

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
            Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.iniColor,p.trial.stimulus.iniSize);
        elseif p.trial.state==p.trial.stimulus.states.STIMON || p.trial.state==p.trial.stimulus.states.INCORRECT
            showStimulus(p);
        elseif p.trial.state == p.trial.stimulus.states.WAIT
            Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.waitColor,p.trial.stimulus.iniSize);
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
        
        %if p.trial.led.state==0
            %turn LED on
            %pds.LED.LEDOn(p);
            %p.trial.led.state=1;
            %note timepoint
            %p.trial.stimulus.timeTrialLedOn = p.trial.ttime;
            %p.trial.stimulus.frameTrialLedOn = p.trial.iFrame;
        %end
        if p.trial.camera.use
            pds.behavcam.triggercam(p,1);
            p.trial.stimulus.timeCamOn = p.trial.ttime;
            p.trial.stimulus.frameCamOn = p.trial.iFrame;
        end
        
        if p.trial.ttime > p.trial.stimulus.baseline && p.trial.ports.position(p.trial.stimulus.side.MIDDLE)==0
            pds.ports.movePort(p.trial.stimulus.side.MIDDLE,1,p);
        end
        
        if activePort==p.trial.stimulus.port.START %start port activated
            %deliver reward
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.START);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.START);
            %turn LED off
            if p.trial.led.state==1
                pds.LED.LEDOff(p);
                p.trial.led.state=0;
            end
            
            %note timepoint
            p.trial.stimulus.timeTrialStartResp = p.trial.ttime;
            p.trial.stimulus.frameTrialStartResp = p.trial.iFrame;
            
            %advance state
            p.trial.state = p.trial.stimulus.states.LICKDELAY;
            p.trial.stimulus.switchVAR = 0;
%                     
%                 pds.datapixx.analogOutTime(0, 1, 0, p.trial.datapixx.dac.sampleRate);  
%                 pds.datapixx.analogOutTime(0, 2, 0, p.trial.datapixx.dac.sampleRate);  
%                 pds.datapixx.analogOutTime(0, 3, 0, p.trial.datapixx.dac.sampleRate);  

        end
        
    case p.trial.stimulus.states.LICKDELAY
        switch p.trial.stimulus.switchVAR
            case 0
                
                if p.trial.ttime < p.trial.stimulus.timeTrialStartResp + 0.5 & activePort==p.trial.stimulus.port.START %start port activated
                    %deliver reward
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.START);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.START);
                    
                end
                
                
                if p.trial.ttime > p.trial.stimulus.timeTrialStartResp + 0.5;
                if p.trial.ports.position(p.trial.stimulus.side.MIDDLE)==1
                    pds.ports.movePort(p.trial.stimulus.side.MIDDLE,0,p);
                end
                p.trial.stimulus.timeTrialWait = p.trial.ttime;
                p.trial.state=p.trial.stimulus.states.WAIT;
                end
                
            case 1
                  p.trial.pldaps.licks = [];
                %give reward
                if p.trial.ttime < p.trial.stimulus.timeResp + p.trial.stimulus.lickdelayR & activePort==p.trial.stimulus.port.RIGHT & activePort == p.trial.side %active port is the correct port 
                    %deliver reward
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
                    %note timepoint
                    p.trial.pldaps.licks = [p.trial.pldaps.licks p.trial.ttime];
                end
                
                if p.trial.ttime < p.trial.stimulus.timeResp + p.trial.stimulus.lickdelayL & activePort==p.trial.stimulus.port.LEFT & activePort == p.trial.side %active port is the correct port
                    %deliver reward
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                   %note timepoint
                    p.trial.pldaps.licks = [p.trial.pldaps.licks p.trial.ttime]; 
                    
                end
                
                if p.trial.ttime > p.trial.stimulus.timeResp + p.trial.stimulus.lickdelay;
                if any(p.trial.ports.position)
                    pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT],0,p);
                end
                p.trial.state=p.trial.stimulus.states.FINALRESP;
                end
                
            case 2
                
                if p.trial.ttime > p.trial.stimulus.timeResp + p.trial.stimulus.forceCorrect_delay;
                    if any(p.trial.ports.position)
                        pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT],0,p);
                    end
                    p.trial.state=p.trial.stimulus.states.FINALRESP;
                end
                
        end
        
    case p.trial.stimulus.states.WAIT
%                 
%                 pds.datapixx.analogOutTime(0, 1, 0, p.trial.datapixx.dac.sampleRate);  
%                 pds.datapixx.analogOutTime(0, 2, 0, p.trial.datapixx.dac.sampleRate);  
%                 pds.datapixx.analogOutTime(0, 3, 0, p.trial.datapixx.dac.sampleRate);  

        if p.trial.ttime > p.trial.stimulus.timeTrialWait + p.trial.stimulus.waitTime;
            p.trial.stimulus.timeTrialStimOn = p.trial.ttime;
            p.trial.state=p.trial.stimulus.states.STIMON;
        end
        
    case p.trial.stimulus.states.STIMON %stimulus shown; port selected in response
%                 
%                 pds.datapixx.analogOutTime(0, 1, 0, p.trial.datapixx.dac.sampleRate);  
%                 pds.datapixx.analogOutTime(0, 2, 0, p.trial.datapixx.dac.sampleRate);  
%                 pds.datapixx.analogOutTime(0, 3, 0, p.trial.datapixx.dac.sampleRate);  

        %wait to make ports available
        if p.trial.ttime > p.trial.stimulus.timeTrialStimOn + p.trial.stimulus.stimON && p.trial.ports.position(p.trial.stimulus.side.LEFT)==0 && p.trial.ports.position(p.trial.stimulus.side.RIGHT)==0;
            pds.ports.movePort(p.trial.side,1,p);
            if p.trial.stimulus.dotCoherence == 1;
                pds.ports.movePort(1 + mod(p.trial.side,2),p.trial.ports.moveBool,p);
            else
                pds.ports.movePort(1+mod(p.trial.side,2),1,p);
            end
            %             pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT],1,p);
        end
        
        %check whether any port chosen
         if length(activePort) > 1 %if more than one port is activated
            
            %retract spouts
            pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT p.trial.stimulus.side.MIDDLE],0,p);
            %wait
            WaitSecs(2);
            %present spouts again
            pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT],1,p);
            
        elseif length(activePort) == 1 & activePort==p.trial.stimulus.port.LEFT | activePort==p.trial.stimulus.port.RIGHT & p.trial.ttime > p.trial.stimulus.timeTrialStimOn + p.trial.stimulus.stimON
            %note time
            p.trial.stimulus.timeTrialFirstResp = p.trial.ttime;
            p.trial.stimulus.frameTrialFirstResp = p.trial.iFrame;
            
            %note response
            %p.trial.stimulus.respTrial=activePort;
            p.trial.stimulus.respTrial=p.trial.ports.status;
            
            %check whether correct port chosen
            correct=checkPortChoice(activePort,p);
            if correct==1
                    p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                    p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
                    if  activePort==p.trial.stimulus.port.RIGHT & activePort == p.trial.side %active port is the correct port
                        %deliver reward
                        amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
                    end
                    if  activePort==p.trial.stimulus.port.LEFT & activePort == p.trial.side %active port is the correct port
                        %deliver reward
                        amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                    end
                %play tone
                pds.audio.playDatapixxAudio(p,'reward_short');
                
                %retract incorrect spout
                if p.trial.side==p.trial.stimulus.side.LEFT
                    if p.trial.ports.position(p.trial.stimulus.side.RIGHT)==1
                        pds.ports.movePort(p.trial.stimulus.side.RIGHT,0,p);
                    end
                end
                if p.trial.side==p.trial.stimulus.side.RIGHT
                    if p.trial.ports.position(p.trial.stimulus.side.LEFT)==1
                        pds.ports.movePort(p.trial.stimulus.side.LEFT,0,p);
                    end
                end
                
                %advance state
                p.trial.stimulus.switchVAR = 1;
                p.trial.state=p.trial.stimulus.states.LICKDELAY;
                p.trial.stimulus.timeResp = p.trial.ttime;
                %note good trial
                p.trial.pldaps.goodtrial = 1;
                
            else
                %play tone
                pds.audio.playDatapixxAudio(p,'breakfix');
                p.trial.pldaps.goodtrial = 0;
                %advance state
                p.trial.state=p.trial.stimulus.states.INCORRECT;
            end
        end
        
        
    case p.trial.stimulus.states.INCORRECT %incorrect port selected for stimulus
        if p.trial.stimulus.forceCorrect == 1 %must give correct response before ending trial
            
            %retract incorrect spout
            if p.trial.side==p.trial.stimulus.side.LEFT
                if p.trial.ports.position(p.trial.stimulus.side.RIGHT)==1
                    pds.ports.movePort(p.trial.stimulus.side.RIGHT,0,p);
                end
            end
            if p.trial.side==p.trial.stimulus.side.RIGHT
                if p.trial.ports.position(p.trial.stimulus.side.LEFT)==1
                    pds.ports.movePort(p.trial.stimulus.side.LEFT,0,p);
                end
            end
            
            %check whether any port chosen
            if activePort==p.trial.stimulus.port.LEFT | activePort==p.trial.stimulus.port.RIGHT
                %check whether correct port chosen
                correct=checkPortChoice(activePort,p);
                if correct==1 %now has chosen correct port
                    p.trial.stimulus.timeResp = p.trial.ttime;
                    p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                    p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
                    
                    if p.trial.ttime < p.trial.stimulus.timeResp + p.trial.stimulus.forceCorrect_delay & activePort==p.trial.stimulus.port.RIGHT 
                        %deliver reward
                        amount=0.05; %p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
                        
                    end
                    
                    if p.trial.ttime < p.trial.stimulus.timeResp + p.trial.stimulus.forceCorrect_delay & activePort==p.trial.stimulus.port.LEFT 
                        %deliver reward
                        amount= 0.05;%p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                        
                    end
                    
                    %advance state
                    p.trial.stimulus.switchVAR = 2;
                    p.trial.state=p.trial.stimulus.states.LICKDELAY;
                    
                end
            end
            
        else %incorrect responses end trial immediately
            %retract spouts
            if any(p.trial.ports.position)
                pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT],0);
            end
            
            %wait for ITI
            if p.trial.ttime > p.trial.stimulus.timeTrialFirstResp + p.trial.stimulus.duration.ITI
                %trial done
                p.trial.state=p.trial.stimulus.states.TRIALCOMPLETE;
                p.trial.flagNextTrial = true;
            end
        end
        
    case p.trial.stimulus.states.FINALRESP
%                 
%                 pds.datapixx.analogOutTime(0, 1, 0, p.trial.datapixx.dac.sampleRate);  
%                 pds.datapixx.analogOutTime(0, 2, 0, p.trial.datapixx.dac.sampleRate);  
%                 pds.datapixx.analogOutTime(0, 3, 0, p.trial.datapixx.dac.sampleRate);  

        if p.trial.camera.use
            pds.behavcam.triggercam(p,0);
            p.trial.stimulus.timeCamOff = p.trial.ttime;
            p.trial.stimulus.frameCamOff = p.trial.iFrame;
        end

        %wait for ITI
        if p.trial.ttime > p.trial.stimulus.timeTrialFinalResp + p.trial.stimulus.duration.ITI + p.trial.stimulus.timeout*(~p.trial.pldaps.goodtrial)
            %trial done
            p.trial.state=p.trial.stimulus.states.TRIALCOMPLETE;
            p.trial.flagNextTrial = true;
        end
        
end




%------------------------------------------------------------------%
%setup trial parameters, prep stimulus as far as possible
function p=trialSetup(p)

%get side for condition
if p.conditions{p.trial.pldaps.iTrial}.side==2
    p.trial.side=p.trial.stimulus.side.LEFT;
else
    p.trial.side=p.trial.stimulus.side.RIGHT;
end
if isfield(p.trialMem,'fracInstruct');
    p.trial.stimulus.fracInstruct = p.trialMem.fracInstruct;
end
% %determine which spouts are presented when stimulus is presented
% p.trial.ports.moveBool = double(rand > p.trial.stimulus.fracInstruct);

if isfield(p.trialMem,'fracInstruct');
    p.trial.stimulus.fracInstruct = p.trialMem.fracInstruct;
end

if ~isfield(p.trialMem,'count') || p.trialMem.count == 0;
    p.trialMem.count = 1;
    p.trialMem.moveBool = zeros(1,10);
    p.trialMem.moveBool(1:round((1 - p.trial.stimulus.fracInstruct)*10)) = 1;
    p.trialMem.moveBool = p.trialMem.moveBool(randperm(10));
end

p.trial.ports.moveBool = p.trialMem.moveBool(p.trialMem.count);
p.trialMem.count = mod(p.trialMem.count+1,11);

if length(p.trial.stimulus.lickdelay) > 1
    p.trial.stimulus.lickdelayL = p.trial.stimulus.lickdelay(1);
    p.trial.stimulus.lickdelayR = p.trial.stimulus.lickdelay(2);
else
    p.trial.stimulus.lickdelayL = p.trial.stimulus.lickdelay;
    p.trial.stimulus.lickdelayR = p.trial.stimulus.lickdelay;
end

%set up initialization stimulus (this could be in settings file)
p.trial.stimulus.iniColor=1;
p.trial.stimulus.iniSize=[910 490 1010 590];
if ~isfield(p.trial.stimulus,'waitColor')
p.trial.stimulus.waitColor = 0.5;
end

%% set up stimulus

DegPerPix = p.trial.display.dWidth/p.trial.display.pWidth;
PixPerDeg = 1/DegPerPix;

%dot size
p.trial.stimulus.dotSizePix = round(p.trial.stimulus.dotSize*PixPerDeg);
%dot coherence
p.trial.stimulus.dotCoherence = p.conditions{p.trial.pldaps.iTrial}.dotCoherence;
%dot speed
p.trial.stimulus.dotSpeed = p.conditions{p.trial.pldaps.iTrial}.dotSpeed;
%direction
p.trial.stimulus.direction = p.conditions{p.trial.pldaps.iTrial}.direction;

%initialize frame
p.trial.stimulus.frameI = 0;
%lifetime
p.trial.stimulus.dotLifetime = p.conditions{p.trial.pldaps.iTrial}.dotLifetime;
% nr dots
if isfield(p.trial.stimulus,'dotDensity')
p.trial.stimulus.nrDots = round(p.trial.display.dWidth*p.trial.display.dHeight*p.trial.stimulus.dotDensity/p.trial.stimulus.dotSize);
end

%initialize dot positions - these need to be in pixels from center
randpos=rand(2,p.trial.stimulus.nrDots); %this gives numbers between 0 and 1
randpos(1,:)=(randpos(1,:)-0.5)*p.trial.display.pWidth;
randpos(2,:)=(randpos(2,:)-0.5)*p.trial.display.pHeight;


%pick color for each dot
p.trial.stimulus.dotcolor=ones(3,p.trial.stimulus.nrDots)*255;
p.trial.stimulus.dotcolor(:,1:round(p.trial.stimulus.fractionBlack*p.trial.stimulus.nrDots))=0;
p.trial.stimulus.dotcolor=p.trial.stimulus.dotcolor(:,randperm(p.trial.stimulus.nrDots));

%initialize noise vector
nrSignal=round(p.trial.stimulus.nrDots*p.trial.stimulus.dotCoherence);
noisevec=zeros(p.trial.stimulus.nrDots,1);
noisevec(1:nrSignal)=1;

%initialize directions: correct displacement for signal, random for noise
%side is either 1 or 2; 1 should equal ori=0, 2 ori=180
randdir=zeros(p.trial.stimulus.nrDots,1);
randdir(1:end)=p.trial.stimulus.direction;
idx=find(noisevec==0);
randdir(idx)=randi([0,359],length(idx),1);


%initialize lifetime vector
if p.trial.stimulus.dotLifetime>0
    lifetime=randi(p.trial.stimulus.dotLifetime,p.trial.stimulus.nrDots,1);
end

%compute nr frames
p.trial.stimulus.nrFrames=p.trial.stimulus.durStim*p.trial.stimulus.frameRate;

%compute speed
deltaF=p.trial.stimulus.dotSpeed*PixPerDeg;


%save misc variables
p.trial.stimulus.randpos = randpos;
p.trial.stimulus.randdir = randdir;
p.trial.stimulus.deltaF = deltaF;
p.trial.stimulus.lifetime = lifetime;

% deal with legacy
if ~isfield(p.trial.stimulus,'nStaticFrames');
    p.trial.stimulus.nStaticFrames = 0;
end

%%

%set state
p.trial.state=p.trial.stimulus.states.START;

%set ports correctly
pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT p.trial.stimulus.side.MIDDLE],0,p);


%show stimulus - handles rotation and movement of grating
function showStimulus(p)
p.trial.stimulus.frameI=p.trial.stimulus.frameI+1;
if p.trial.stimulus.frameI<=p.trial.stimulus.nrFrames
    f = p.trial.stimulus.frameI;
    randpos = p.trial.stimulus.randpos;
    randdir = p.trial.stimulus.randdir;
    deltaF = p.trial.stimulus.deltaF;
    lifetime = p.trial.stimulus.lifetime;
    
    if f > p.trial.stimulus.nStaticFrames;
    %compute vectors for necessary frames
    %move all dots according to their direction
    xproj=cos(randdir*pi/180);
    yproj=-sin(randdir*pi/180);
    
    randpos(1,:)=randpos(1,:)+deltaF*xproj';
    randpos(2,:)=randpos(2,:)+deltaF*yproj';
    
    %now deal with wrap around - we pick the axis on which to replot a dot
    %based on the dots direction
    idx=find(abs(randpos(1,:))>p.trial.display.pWidth/2 | abs(randpos(2,:))>p.trial.display.pHeight/2);
    
    rvec=rand(size(idx)); %btw 0 and 1
    for i=1:length(idx)
        if rvec(i)<=abs(xproj(idx(i)))/(abs(xproj(idx(i)))+abs(yproj(idx(i))))
            randpos(1,idx(i))=-1*sign(xproj(idx(i)))*p.trial.display.pWidth/2;
            randpos(2,idx(i))=(rand(1)-0.5)*p.trial.display.pHeight;
        else
            randpos(1,idx(i))=(rand(1)-0.5)*p.trial.display.pWidth;
            randpos(2,idx(i))=-1*sign(yproj(idx(i)))*p.trial.display.pHeight/2;
        end
    end
    
    
    %if lifetime is expired, randomly assign new direction
    if p.trial.stimulus.dotLifetime>0
        idx=find(lifetime==0);
        %directions are drawn based on coherence level
        rvec=rand(size(idx));
        for i=1:length(idx)
            if rvec(i)<p.trial.stimulus.dotCoherence %these get moved with the signal
                randdir(idx(i))=p.trial.stimulus.direction;
            else
                randdir(idx(i))=randi([0,359],1,1);
            end
        end
        
        lifetime=lifetime-1;
        lifetime(idx)=p.trial.stimulus.dotLifetime;
    end
    end
    p.trial.stimulus.lifetime = lifetime;
    p.trial.stimulus.dotpos{f}=randpos;
    p.trial.stimulus.randpos = randpos;
    p.trial.stimulus.randdir = randdir;
    Screen('DrawDots', p.trial.display.ptr, p.trial.stimulus.dotpos{p.trial.stimulus.frameI}, ...
        p.trial.stimulus.dotSizePix, p.trial.stimulus.dotcolor, ...
        [p.trial.display.pWidth/2 p.trial.display.pHeight/2],1);
end


%------------------------------------------------------------------%
%display stats at end of trial
function cleanUpandSave(p)
tic
disp('----------------------------------')
disp(['Trialno: ' num2str(p.trial.pldaps.iTrial)])

%show reward amount
if p.trial.pldaps.draw.reward.show
    pds.behavior.reward.showReward(p,{'S';'L';'R'})
end

%show frac instruct
disp(p.trial.stimulus.fracInstruct);


%+/- frac instruct
if p.trial.userInput==1
    p.trialMem.fracInstruct = p.trial.stimulus.fracInstruct - 0.1;
    disp('decreased fracInstruct')
end
if p.trial.userInput==2
    p.trialMem.fracInstruct = p.trial.stimulus.fracInstruct + 0.1;
    disp('increased fracInstruct')
end
if p.trial.userInput==3
    p.trialMem.fracInstruct = 1;
    p.trialMem.count = 0;
    disp('increased fracInstruct to 1, effective immediately')
end

%show stats
pds.behavior.countTrial(p,p.trial.pldaps.goodtrial);
num2str(vertcat(p.trialMem.stats.val,p.trialMem.stats.count.Ntrial,...
    p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100))


% disp(['C: ' num2str(p.trialMem.stats.val)])
% disp(['N: ' num2str(p.trialMem.stats.count.Ntrial)])
% disp(['P: ' num2str(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100)])



%%%%%%Helper functions
%-------------------------------------------------------------------%
%check whether a particular port choice is correct
function correct=checkPortChoice(activePort,p)

correct=0;

switch p.trial.side
    case p.trial.stimulus.side.LEFT
        if activePort==p.trial.stimulus.side.LEFT
            correct=1;
            p.trial.stimulus.switchVAR = 1;
        end
    case p.trial.stimulus.side.RIGHT
        if activePort==p.trial.stimulus.side.RIGHT
            correct=1;
            p.trial.stimulus.switchVAR = 2;
        end
end

