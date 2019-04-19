function drifting_fixation_2P(p,state)

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
            Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.waitColor,[0 0 1920 1080]);
            %Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.iniColor,p.trial.stimulus.iniSize);
            %Screen('DrawTexture',p.trial.display.ptr, p.trial.stimulus.initex,[],p.trial.stimulus.dstRect,p.trial.stimulus.refangle,0);
        elseif p.trial.state==p.trial.stimulus.states.STIMON 
           showStimulus(p)
        elseif p.trial.state == p.trial.stimulus.states.WAIT
            Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.waitColor,[0 0 1920 1080]);
        end
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        cleanUpandSave(p);
        
end




%-------------------------------------------------------------------%
%check port status and set events accordingly
%check port status and set events accordingly
function p=checkState(p)

activePort=find(p.trial.ports.status==1);


switch p.trial.state
        case p.trial.stimulus.states.BASELINE
            
        if p.trial.ttime > p.trial.stimulus.baseline
            p.trial.state = p.trial.stimulus.states.START;
        end
    case p.trial.stimulus.states.START 
        
        if p.trial.ttime > p.trial.stimulus.reference_baseline && p.trial.ports.position(p.trial.ports.dio.channel.MIDDLE)==0
            pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,1,p);
        end
        
        if activePort==p.trial.stimulus.port.START %start port activated
            
            %note timepoint
            p.trial.stimulus.timeTrialStartResp = p.trial.ttime;
            p.trial.stimulus.frameTrialStartResp = p.trial.iFrame;
            
            %advance state
            p.trial.state = p.trial.stimulus.states.LICKDELAY;
            p.trial.stimulus.switchVAR = 0;
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
                if p.trial.ports.position(p.trial.ports.dio.channel.MIDDLE)==1
                    pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,0,p);
                end
                p.trial.stimulus.timeTrialWait = p.trial.ttime;
                p.trial.state=p.trial.stimulus.states.WAIT;
                if ~isfield(p.trial,'triggerState') | p.trial.triggerState ~= p.trial.trigger.states.WAIT;
                    % open laser shutter, send trigger, note time
                    p = pds.sbserver.shutter2P(p,'1');
                    p = pds.daq_com.send_daq(p,p.trial.daq.trigger.trialstart);
                    p.trial.TrialStartTrigger = p.trial.ttime;
                    p.trial.triggerState = p.trial.trigger.states.WAIT;
                end
                end
            case 1
                p.trial.pldaps.licks = [];
            %give reward
                if p.trial.ttime < p.trial.stimulus.timeTrialFinalResp + p.trial.stimulus.lickdelay & activePort==p.trial.stimulus.port.START %start port activated
                    %deliver reward
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.START);
                    
                end
                
                if p.trial.ttime > p.trial.stimulus.timeTrialFinalResp + p.trial.stimulus.lickdelay;
                if p.trial.ports.position(p.trial.ports.dio.channel.MIDDLE)==1
                    pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,0,p);
                end
                p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
                p.trial.state=p.trial.stimulus.states.FINALRESP;
                end
            
        end
        
    case p.trial.stimulus.states.WAIT
        if p.trial.ttime > p.trial.stimulus.timeTrialWait + p.trial.stimulus.waitTime;
                p.trial.stimulus.timeTrialStimOn = p.trial.ttime;
                p.trial.state=p.trial.stimulus.states.STIMON;
                p.trial.iFrame0 = p.trial.iFrame;
                p.trial.iFrame2 = p.trial.iFrame - p.trial.iFrame0;
        end
        
    case p.trial.stimulus.states.STIMON %stimulus shown; port selected in response
         % trigger the laser
        if p.trial.triggerState ~= p.trial.trigger.states.STIMON
            p = pds.daq_com.send_daq(p,p.trial.daq.trigger.stimon);
            p.trial.StimOnTrigger = p.trial.ttime;
            p.trial.triggerState = p.trial.trigger.states.STIMON;
        end
        p.trial.iFrame2 = p.trial.iFrame - p.trial.iFrame0;
         %wait to make ports available
        if p.trial.ttime > p.trial.stimulus.timeTrialStimOn + p.trial.stimulus.stimON && p.trial.ports.position(p.trial.ports.dio.channel.MIDDLE)==0
            pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,1,p);
        end
        
        
        %check whether any port chosen
       if activePort==p.trial.stimulus.port.START %start port activated
            %note time
                p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
                %play tone
                pds.audio.playDatapixxAudio(p,'reward_short');
                
                %shutter laser, trigger daq
                if p.trial.triggerState ~= p.trial.trigger.states.LICKDELAY
                    p = pds.daq_com.send_daq(p,0);
                    p = pds.sbserver.shutter2P(p,'0');
                    p.trial.triggerState = p.trial.trigger.states.LICKDELAY;
                    p.trial.TriggerTrialFinish = p.trial.ttime;
                end
                
                %advance state
                p.trial.stimulus.switchVAR = 1;
                p.trial.state=p.trial.stimulus.states.LICKDELAY;
                p.trial.stimulus.timeResp = p.trial.ttime;
           
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

p.trial.stimulus.iniColor=1;
p.trial.stimulus.iniSize=[910 490 1010 590];

p.trial.stimulus.waitColor = 0.5;

%set up initialization stimulus (this could be in settings file)
%shorthand to make rest easier
        p.trial.ori=p.conditions{p.trial.pldaps.iTrial}.direction;
        p.trial.t_period = p.conditions{p.trial.pldaps.iTrial}.t_period;
        p.trial.stimulus.phase = mod(180, (rand < 0.5)*180 + 180); % phase is random 0 or 180
        if ~isfield(p.trial.stimulus,'shift')
            p.trial.stimulus.shift = 0;
        end
        p.trial.stimulus.fullField = p.conditions{p.trial.pldaps.iTrial}.fullField;
        %generate mask
        xdom=[1:p.trial.display.pWidth]-p.trial.display.pWidth/2;
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
        stimsize=stimsize+1/p.trial.stimulus.sf; %deg
        stimsizeN=deg2pixNL(p,stimsize,'ceil',2);
        
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
        p.trial.stimulus.pCycle=deg2pixNL(p,1/p.trial.stimulus.sf,'none',2);
        if p.trial.t_period >0 
            p.trial.stimulus.dFrame=p.trial.stimulus.pCycle/p.trial.t_period;
        else
            p.trial.stimulus.dFrame = 0;
        end
%wake daq
p = pds.daq_com.send_daq(p,0);
%set state
p.trial.state=p.trial.stimulus.states.BASELINE;

%set ports correctly
pds.ports.movePort([p.trial.ports.dio.channel.LEFT p.trial.ports.dio.channel.RIGHT p.trial.ports.dio.channel.MIDDLE],0,p);

function showStimulus(p)
        %determine offset
        xoffset = mod((p.trial.iFrame2)*p.trial.stimulus.dFrame+p.trial.stimulus.phase/360*p.trial.stimulus.pCycle,p.trial.stimulus.pCycle*1.1);
        stimSrc=[xoffset 0 xoffset + p.trial.stimulus.sN-1 p.trial.stimulus.sN-1];
        
        Screen('BlendFunction', p.trial.display.ptr, GL_SRC_ALPHA, GL_ONE);
        Screen('DrawTexture', p.trial.display.ptr, p.trial.gtxtr, stimSrc, p.trial.stimulus.sDst,p.trial.ori,[],0.5);
        
        if ~p.trial.stimulus.fullfield
            Screen('BlendFunction', p.trial.display.ptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('DrawTexture', p.trial.display.ptr, p.trial.masktxtr);
        end



%------------------------------------------------------------------%
%display stats at end of trial
function cleanUpandSave(p)
tic
disp('----------------------------------')
disp(['Trialno: ' num2str(p.trial.pldaps.iTrial)])
disp(['Condition: ' num2str(p.trial.ori)])
%show reward amount
if p.trial.pldaps.draw.reward.show
    pds.behavior.reward.showReward(p,{'S1';'S2'})
end

% disp(['C: ' num2str(p.trialMem.stats.val)])
% disp(['N: ' num2str(p.trialMem.stats.count.Ntrial)])
% disp(['P: ' num2str(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100)])



