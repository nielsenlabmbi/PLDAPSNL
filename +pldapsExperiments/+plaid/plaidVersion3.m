function plaidVersion3(p,state)

%version 1: only middle stimulus to introduce ferret to middle port

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
            p.trial.led.state=1;
            %note timepoint
            p.trial.stimulus.timeTrialLedOn = p.trial.ttime;
            p.trial.stimulus.frameTrialLedOn = p.trial.iFrame;
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
                amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.MIDDLE);
                pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.MIDDLE);
                
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
                    
                    
                    %give (small) reward
                    amount=p.trial.behavior.reward.propAmtIncorrect*p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.MIDDLE);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.MIDDLE);
                    
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
 
%get side for condition
swi
if p.conditions{p.trial.pldaps.iTrial}.side==3
    p.trial.side=p.trial.stimulus.side.MIDDLE;
end

%shorthand to make rest easier
p.trial.ori=p.conditions{p.trial.pldaps.iTrial}.ori;
p.trial.plaid=p.conditions{p.trial.pldaps.iTrial}.plaid;

%generate mask
xdom=[1:p.trial.display.pWidth]-p.trial.display.pWidth/2;
ydom=[1:p.trial.display.pHeight]-p.trial.display.pHeight/2;
[xdom,ydom] = meshgrid(xdom,ydom); %this results in a matrix of dimension height x width
r = sqrt(xdom.^2 + ydom.^2);

%transform mask parameters into pixel
sigmaN=deg2pix(p,p.trial.stimulus.sigma,'round',2);
mN=deg2pix(p,p.trial.stimulus.maskLimit,'round',2);

%compute mask
maskT = exp(-.5*(r-mN).^2/sigmaN.^2);
maskT(r<mN) = 1;

mask = 0.5*ones(p.trial.display.pHeight,p.trial.display.pWidth,2);
mask(:,:,2) = 1-maskT;

p.trial.masktxtr = Screen(p.trial.display.ptr, 'MakeTexture', mask,[],[],2); 

%set up one line of grating (one grating sufficient even for plaid)
%stimuli will need to be larger to deal with rotation
stimsize=2*sqrt(2*(p.trial.stimulus.radius).^2); %deg
p.trial.stimulus.sN=deg2pix(p,stimsize,'ceil',2); %pixel

%add space for sliding window
stimsize=stimsize+1/p.trial.stimulus.sf; %deg
stimsizeN=deg2pix(p,stimsize,'ceil',2);

x_ecc=linspace(-stimsize/2,stimsize/2,stimsizeN); %deg
sdom = x_ecc*p.trial.stimulus.sf*2*pi; %radians
grating = cos(sdom);

p.trial.gtxtr = Screen('MakeTexture',p.trial.display.ptr, grating,[],[],2);

%compute a few additional parameters that will be needed later
%destination rectangle
x_pos=p.trial.display.pWidth/2;
y_pos=p.trial.display.pHeight/2;

p.trial.stimulus.sDst=[x_pos-floor(p.trial.stimulus.sN/2)+1 y_pos-floor(p.trial.stimulus.sN/2)+1 ...
    x_pos+ceil(p.trial.stimulus.sN/2) y_pos+ceil(p.trial.stimulus.sN/2)]';

%shift per frame
p.trial.stimulus.pCycle=deg2pix(p,1/p.trial.stimulus.sf,'none',2);
p.trial.stimulus.dFrame=p.trial.stimulus.pCycle/p.trial.stimulus.t_period;

%set state
p.trial.state=p.trial.stimulus.states.START;


%------------------------------------------------------------------%
%show stimulus - handles rotation and movement of grating
function showStimulus(p)

%determine offset
xoffset = mod((p.trial.iFrame-1)*p.trial.stimulus.dFrame+p.trial.stimulus.phase/360*p.trial.stimulus.pCycle,p.trial.stimulus.pCycle);
stimSrc=[xoffset 0 xoffset + p.trial.stimulus.sN-1 p.trial.stimulus.sN-1];

if p.trial.plaid==1
    xoffset2 = mod((p.trial.iFrame-1)*p.trial.stimulus.dFrame+p.trial.stimulus.phase/360*p.trial.stimulus.pCycle,p.trial.stimulus.pCycle);
    stimSrc2=[xoffset2 0 xoffset2 + p.trial.stimulus.sN p.trial.stimulus.sN];
    ori2=p.trial.ori+p.trial.stimulus.iAngle;
end


Screen('BlendFunction', p.trial.display.ptr, GL_SRC_ALPHA, GL_ONE);
if p.trial.plaid==1
    Screen('DrawTexture', p.trial.display.ptr, p.trial.gtxtr, stimSrc2, p.trial.stimulus.sDst,ori2,[],0.5);
end

Screen('DrawTexture', p.trial.display.ptr, p.trial.gtxtr, stimSrc, p.trial.stimulus.sDst,p.trial.ori,[],0.5);
Screen('BlendFunction', p.trial.display.ptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('DrawTexture', p.trial.display.ptr, p.trial.masktxtr);


%------------------------------------------------------------------%
%display stats at end of trial
function cleanUpandSave(p)

disp('----------------------------------')
disp(['Trialno: ' num2str(p.trial.pldaps.iTrial)])
%show reward amount
if p.trial.pldaps.draw.reward.show
    pds.behavior.reward.showReward(p,{'S';'L';'R';'M'})
end


%show stats
pds.behavior.countTrial(p,p.trial.pldaps.goodtrial);
disp(['C: ' num2str(p.trialMem.stats.val)])
disp(['N: ' num2str(p.trialMem.stats.count.Ntrial)])
disp(['P: ' num2str(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100)])

    

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

   