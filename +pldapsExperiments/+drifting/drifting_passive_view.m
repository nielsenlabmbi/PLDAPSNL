function drifting_passive_view(p,state)

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

switch p.trial.state
    case p.trial.stimulus.states.BASELINE
        if ~isfield(p.trial,'triggerState') | p.trial.triggerState ~= p.trial.trigger.states.TRIALSTART;
        % open laser shutter
            p = pds.sbserver.shutter2P(p,'1');
        % send trigger, note time
            p = pds.daq_com.send_daq(p,p.trial.daq.trigger.trialstart); %for 2P
            p = pds.intan.send_intan(p,p.trial.ephys.trigger.trialstart,1); %for intan
            p.trial.TrialStartTrigger = p.trial.ttime;
            p.trial.triggerState = p.trial.trigger.states.TRIALSTART;
        end
        
        if p.trial.ttime > p.trial.stimulus.baseline
            p.trial.state = p.trial.stimulus.states.START;
        end
    case p.trial.stimulus.states.START 

        if p.trial.ttime > p.trial.stimulus.reference_baseline
            %note timepoint
            p.trial.stimulus.timeTrialStimOn = p.trial.ttime;
            p.trial.stimulus.frameTrialStimOn = p.trial.iFrame;
            
            %advance state
            if p.trial.triggerState ~= p.trial.trigger.states.STIMON
                p = pds.daq_com.send_daq(p,p.trial.daq.trigger.stimon); %for 2P
                p = pds.intan.send_intan(p,p.trial.ephys.trigger.stimon,1); %for intan
                p.trial.StimOnTrigger = p.trial.ttime;
                p.trial.triggerState = p.trial.trigger.states.STIMON;
            end
            p.trial.state = p.trial.stimulus.states.STIMON;
            p.trial.iFrame0 = p.trial.iFrame;
                p.trial.iFrame2 = p.trial.iFrame - p.trial.iFrame0;
        end
        
        
    case p.trial.stimulus.states.STIMON %stimulus shown; port selected in response
        p.trial.iFrame2 = p.trial.iFrame - p.trial.iFrame0;
        
        if p.trial.ttime > p.trial.stimulus.timeTrialStimOn + p.trial.stimulus.stimdur
            p = pds.intan.send_intan(p,p.trial.ephys.trigger.stimon,0); %for intan
            p = pds.daq_com.send_daq(p,p.trial.daq.trigger.stimon); %for 2P
            p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
            p.trial.state = p.trial.stimulus.states.FINALRESP;
        end
        
    case p.trial.stimulus.states.FINALRESP
        %wait for ITI
        if p.trial.ttime > p.trial.stimulus.timeTrialFinalResp + p.trial.stimulus.duration.ITI
            %trial done
            p.trial.state=p.trial.stimulus.states.TRIALCOMPLETE;
            if p.trial.triggerState ~= p.trial.trigger.states.TRIALCOMPLETE
                p = pds.daq_com.send_daq(p,p.trial.daq.trigger.trialfinish);
                p = pds.intan.send_intan(p,p.trial.ephys.trigger.trialstart,0); %for intan
                p.trial.triggerState = p.trial.daq.trigger.trialfinish;
                p.trial.TriggerTrialFinish = p.trial.ttime;
            end
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
        
        if ~p.trial.stimulus.fullField
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



