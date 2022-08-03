function tryingtofind_port(p,state)

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
            Screen('DrawTexture',p.trial.display.ptr, p.trial.stimulus.initex,[],p.trial.stimulus.dstRect,p.trial.stimulus.refangle,0);
        elseif p.trial.state==p.trial.stimulus.states.STIMON || p.trial.state==p.trial.stimulus.states.INCORRECT
            showStimulus(p);
        elseif p.trial.state == p.trial.stimulus.states.WAIT
            Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.waitColor,[0 0 1920 1080]);
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
if p.conditions{p.trial.pldaps.iTrial}.side==2
    p.trial.side=p.trial.stimulus.side.LEFT;
else
    p.trial.side=p.trial.stimulus.side.RIGHT;
end

%get instructive fraction
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
    
%set up initialization stimulus (this could be in settings file)
p.trial.stimulus.iniColor=0;
inibar = 248*ones(10,1);
p.trial.stimulus.initex = Screen('MakeTexture',p.trial.display.ptr,inibar);
[s1,s2] = size(inibar);
dstRect = [0 0 s1 s2].*40;
p.trial.stimulus.dstRect = CenterRectOnPointd(dstRect,960,540);
p.trial.stimulus.refangle = p.conditions{p.trial.pldaps.iTrial}.angle;
p.trial.stimulus.waitColor = 0.5;

p.trial.stimulus.grat_direction = p.conditions{p.trial.pldaps.iTrial}.grat_direction;
%% setup stimuli
switch p.trial.type
    case 1 %gratings
        %shorthand to make rest easier
        %p.trial.ori=p.conditions{p.trial.pldaps.iTrial}.direction;
        p.trial.ori=180;
        p.trial.t_period = p.conditions{p.trial.pldaps.iTrial}.t_period;
        p.trial.stimulus.phase = mod(180, (rand < 0.5)*180 + 180); % phase is random 0 or 180
        if ~isfield(p.trial.stimulus,'shift')
            p.trial.stimulus.shift = 0;
        end
        %generate mask
        xdom=[1:p.trial.display.pWidth]-p.trial.display.pWidth/2-p.trial.stimulus.shift(p.trial.side);
        ydom=[1:p.trial.display.pHeight]-p.trial.display.pHeight/2;
        [xdom,ydom] = meshgrid(xdom,ydom); %this results in a matrix of dimension height x width
        r = sqrt(xdom.^2 + ydom.^2);
        
        %transform mask parameters into pixel
        sigmaN=deg2pixNL(p,p.trial.stimulus.sigma,'round',2);
        mN=deg2pixNL(p,p.trial.stimulus.maskLimit,'round',2);
        
        %compute mask
        maskT = exp(-.5*(r-mN).^2/sigmaN.^2);
        maskT(r<mN) = 1;
        
        mask = 0.5*ones(p.trial.display.pHeight,p.trial.display.pWidth,2);
        mask(:,:,2) = 1-maskT;
        
        p.trial.masktxtr = Screen(p.trial.display.ptr, 'MakeTexture', mask,[],[],2);
        
        %set up one line of grating 
        %stimuli will need to be larger to deal with rotation
        stimsize=2*sqrt(2*(p.trial.stimulus.radius).^2); %deg
        p.trial.stimulus.sN=deg2pixNL(p,stimsize,'ceil',2); %pixel
        
        %add space for sliding window
        stimsize=stimsize+1/p.trial.stimulus.sf; %deg %%%changing this
        stimsizeN=deg2pixNL(p,stimsize,'ceil',2);
        
        x_ecc=linspace(-stimsize/2,stimsize/2,stimsizeN); %deg
        sdom = x_ecc*p.trial.stimulus.sf*2*pi; %radians
        grating = cos(sdom);
        
        p.trial.gtxtr = Screen('MakeTexture',p.trial.display.ptr, grating,[],[],2);
        
        %compute a few additional parameters that will be needed later
        %destination rectangle
        x_pos=p.trial.display.pWidth/2;
        y_pos=p.trial.display.pHeight/2;
        
%         p.trial.stimulus.sDst=[x_pos-floor(p.trial.stimulus.sN/2)+1 y_pos-floor(p.trial.stimulus.sN/2)+1 ...
%             x_pos+ceil(p.trial.stimulus.sN/2) y_pos+ceil(p.trial.stimulus.sN/2)]';
%         
        p.trial.stimulus.sDst=[0 0 x_pos*3 y_pos*3]';
        %shift per frame
        p.trial.stimulus.pCycle=deg2pixNL(p,1/p.trial.stimulus.sf,'none',2);
        if p.trial.t_period >0 
            p.trial.stimulus.dFrame=p.trial.stimulus.pCycle/p.trial.t_period;
        else
            p.trial.stimulus.dFrame = 0;
        end

    case 2 %dots
        DegPerPix = p.trial.display.dWidth/p.trial.display.pWidth;
        PixPerDeg = 1/DegPerPix;
        
        %dot size
        p.trial.stimulus.dotSizePix = round(p.trial.stimulus.dotSize*PixPerDeg);
        %dot coherence
        p.trial.stimulus.dotCoherence = p.conditions{p.trial.pldaps.iTrial}.dotCoherence;
        %dot speed
        p.trial.stimulus.dotSpeed = p.conditions{p.trial.pldaps.iTrial}.dotSpeed;
        %direction
        p.trial.stimulus.direction = mod(p.conditions{p.trial.pldaps.iTrial}.direction,180);
        %initialize frame
        p.trial.stimulus.frameI = 0;
        %lifetime
        p.trial.stimulus.dotLifetime = p.conditions{p.trial.pldaps.iTrial}.dotLifetime;
        
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
end

%%

%set state
p.trial.state=p.trial.stimulus.states.START;

%set ports correctly
%pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT p.trial.stimulus.side.MIDDLE],0,p);


%show stimulus - handles rotation and movement of grating
function showStimulus(p)
switch p.trial.type
    case 1 %gratings/plaids
        %determine offset
        
        if p.trial.stimulus.grat_direction == 0
            xoffset = mod((p.trial.iFrame)*p.trial.stimulus.dFrame+p.trial.stimulus.phase/360*p.trial.stimulus.pCycle,p.trial.stimulus.pCycle*1.1);
        else
            xoffset =  -1 * mod((p.trial.iFrame)*p.trial.stimulus.dFrame+p.trial.stimulus.phase/360*p.trial.stimulus.pCycle,p.trial.stimulus.pCycle*1.1);
        end

        stimSrc=[xoffset 0 xoffset + p.trial.stimulus.sN-1 p.trial.stimulus.sN-1];

        
        Screen('BlendFunction', p.trial.display.ptr, GL_SRC_ALPHA, GL_ONE);
        Screen('DrawTexture', p.trial.display.ptr, p.trial.gtxtr, stimSrc, p.trial.stimulus.sDst,p.trial.ori,[],0.5);
        
        if p.trial.stimulus.fullfield == 0
            Screen('BlendFunction', p.trial.display.ptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('DrawTexture', p.trial.display.ptr, p.trial.masktxtr);
        end
        
    case 2 %dots
        p.trial.stimulus.frameI=p.trial.stimulus.frameI+1;
        if p.trial.stimulus.frameI<=p.trial.stimulus.nrFrames
            f = p.trial.stimulus.frameI;
            randpos = p.trial.stimulus.randpos;
            randdir = p.trial.stimulus.randdir;
            deltaF = p.trial.stimulus.deltaF;
            lifetime = p.trial.stimulus.lifetime;
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
            p.trial.stimulus.lifetime = lifetime;
            p.trial.stimulus.dotpos{f}=randpos;
            p.trial.stimulus.randpos = randpos;
            p.trial.stimulus.randdir = randdir;
            Screen('DrawDots', p.trial.display.ptr, p.trial.stimulus.dotpos{p.trial.stimulus.frameI}, ...
                p.trial.stimulus.dotSizePix, p.trial.stimulus.dotcolor, ...
                [p.trial.display.pWidth/2 p.trial.display.pHeight/2],1);
        end
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
    
% 
% %------------------------------------------------------------------%
% %display stats at end of trial
% function cleanUpandSave(p)
% tic
% disp('----------------------------------')
% disp(['Trialno: ' num2str(p.trial.pldaps.iTrial)])
% 
% %show reward amount
% if p.trial.pldaps.draw.reward.show
%     pds.behavior.reward.showReward(p,{'S';'L';'R'})
% end
% 
% %show frac instruct
% disp(p.trial.stimulus.fracInstruct);
% 
% 
% %+/- frac instruct
% if p.trial.userInput==1
%     p.trialMem.fracInstruct = p.trial.stimulus.fracInstruct - 0.1;
%     disp('decreased fracInstruct')
% end
% if p.trial.userInput==2
%     p.trialMem.fracInstruct = p.trial.stimulus.fracInstruct + 0.1;
%     disp('increased fracInstruct')
% end
% if p.trial.userInput==3
%     p.trialMem.fracInstruct = 1;
%     p.trialMem.count = 0;
%     disp('increased fracInstruct to 1')
% end
% 
% %show stats
% pds.behavior.countTrial(p,p.trial.pldaps.goodtrial);
% num2str(vertcat(p.trialMem.stats.val,p.trialMem.stats.count.Ntrial,...
%     p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100))
% 
% 
% % disp(['C: ' num2str(p.trialMem.stats.val)])
% % disp(['N: ' num2str(p.trialMem.stats.count.Ntrial)])
% % disp(['P: ' num2str(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100)])



% %%%%%%Helper functions
% %-------------------------------------------------------------------%
% %check whether a particular port choice is correct
% function correct=checkPortChoice(activePort,p)
% 
% correct=0;
% 
% switch p.trial.side
%     case p.trial.stimulus.side.LEFT
%         if activePort==p.trial.stimulus.side.LEFT
%             correct=1;
%             p.trial.stimulus.switchVAR = 1;
%         end
%     case p.trial.stimulus.side.RIGHT
%         if activePort==p.trial.stimulus.port.RIGHT
%             correct=1;
%             p.trial.stimulus.switchVAR = 2; 
%         end
% end

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