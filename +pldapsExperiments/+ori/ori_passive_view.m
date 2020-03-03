function ori_passive_view(p,state)

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
        elseif p.trial.state==p.trial.stimulus.states.STIMON & p.trial.stimulus.displacement >= 0
            Screen('DrawTexture',p.trial.display.ptr,p.trial.gratTex,[],p.trial.gratPos,0);
        elseif p.trial.state == p.trial.stimulus.states.WAIT | p.trial.state == p.trial.stimulus.states.STIMON & p.trial.stimulus.displacement < 0
            Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.waitColor,[0 0 1920 1080]);
        end
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        cleanUpandSave(p);
        
end




%-------------------------------------------------------------------%
function p=checkState(p)

switch p.trial.state
    case p.trial.stimulus.states.BASELINE
        if p.trial.ttime > p.trial.stimulus.baseline
            p.trial.state = p.trial.stimulus.states.START;
            p.trial.startTime = p.trial.ttime;
            if ~isfield(p.trial,'triggerState') | p.trial.triggerState ~= p.trial.trigger.states.TRIALSTART;
                % open laser shutter
                p = pds.sbserver.shutter2P(p,'1');
                % send trigger, note time
                p = pds.daq_com.send_daq(p,p.trial.daq.trigger.trialstart); %for 2P
                p = pds.sbserver.send_sbserver(p,sprintf('M%s',strcat('Trialno.',num2str(p.trial.pldaps.iTrial))));
                
                p = pds.intan.send_intan(p,p.trial.ephys.trigger.trialstart,1); %for intan
                p.trial.TrialStartTrigger = p.trial.ttime;
                p.trial.triggerState = p.trial.trigger.states.TRIALSTART;
            end
            
        end
    case p.trial.stimulus.states.START 

        if p.trial.ttime > p.trial.startTime + p.trial.stimulus.reference_baseline
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
            %p.trial.iFrame0 = p.trial.iFrame;
               % p.trial.iFrame2 = p.trial.iFrame - p.trial.iFrame0;
        end
        
        
    case p.trial.stimulus.states.STIMON %stimulus shown; port selected in response
        %p.trial.iFrame2 = p.trial.iFrame - p.trial.iFrame0;
       
        if p.trial.ttime > p.trial.stimulus.timeTrialStimOn + p.trial.stimulus.stimdur
            p = pds.intan.send_intan(p,p.trial.ephys.trigger.stimon,0); %for intan
            p = pds.daq_com.send_daq(p,p.trial.daq.trigger.trialfinish); %for 2P
            p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
            p.trial.state = p.trial.stimulus.states.FINALRESP;
        end
        
    case p.trial.stimulus.states.FINALRESP
        %wait for ITI
        if p.trial.ttime > p.trial.stimulus.timeTrialFinalResp + p.trial.stimulus.duration.ITI
            %trial done
            p.trial.state=p.trial.stimulus.states.TRIALCOMPLETE;
            if p.trial.triggerState ~= p.trial.trigger.states.TRIALCOMPLETE
                p = pds.daq_com.send_daq(p,0);
                p = pds.sbserver.shutter2P(p,'0');
                p = pds.intan.send_intan(p,p.trial.ephys.trigger.trialstart,0); %for intan
                p.trial.triggerState = p.trial.trigger.states.TRIALCOMPLETE;
                p.trial.TriggerTrialFinish = p.trial.ttime;
            end
            p.trial.flagNextTrial = true;
        end
        
end


%------------------------------------------------------------------%
%setup trial parameters, prep stimulus as far as possible
function p=trialSetup(p)



%set up initialization stimulus (this could be in settings file)
p.trial.stimulus.iniColor=1;
p.trial.stimulus.iniSize=[910 490 1010 590];

p.trial.stimulus.waitColor = 0.5;

%set up stimulus
p.trial.stimulus.refangle = p.conditions{p.trial.pldaps.iTrial}.angle;
p.trial.stimulus.displacement=p.conditions{p.trial.pldaps.iTrial}.displacement;
p.trial.stimulus.rotation = p.conditions{p.trial.pldaps.iTrial}.rotation;
p.trial.stimulus.sf = p.conditions{p.trial.pldaps.iTrial}.sf;
p.trial.stimulus.angle = p.conditions{p.trial.pldaps.iTrial}.angle + p.trial.stimulus.rotation*p.trial.stimulus.displacement;
p.trial.stimulus.phase = mod(180, (rand < 0.5)*180 + 180); % phase is random 0 or 180
%p.trial.stimulus.phase = p.conditions{p.trial.pldaps.iTrial}.phase; % phase is pseudorandom
p.trial.stimulus.range = p.conditions{p.trial.pldaps.iTrial}.range;
p.trial.stimulus.fullField = p.conditions{p.trial.pldaps.iTrial}.fullField;
%make grating

    % GET GRATING SPECIFICATIONS
    ApertureDeg = 2*p.trial.stimulus.radius;

    % CREATE A MESHGRID THE SIZE OF THE GRATING
    x=linspace(-(p.trial.display.dWidth/2),p.trial.display.dWidth/2,p.trial.display.pWidth);
    y=linspace(-(p.trial.display.dHeight/2),p.trial.display.dHeight/2,p.trial.display.pHeight);
    [x,y] = meshgrid(x,y);

%     x=[1:p.trial.display.pWidth]-p.trial.display.pWidth/2-p.trial.stimulus.shift(p.trial.side);
%     y=[1:p.trial.display.pHeight]-p.trial.display.pHeight/2;
%     [x,y] = meshgrid(x,y);
    
    % Transform to account for orientation
    sdom=x*cos(p.trial.stimulus.angle*pi/180)-y*sin(p.trial.stimulus.angle*pi/180);

    % GRATING
    sdom=sdom*p.trial.stimulus.sf*2*pi;
    sdom1=cos(sdom-p.trial.stimulus.phase*pi/180);

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

%wake daq
p = pds.daq_com.send_daq(p,0);
%set state
p.trial.state=p.trial.stimulus.states.BASELINE;
%set ports correctly
pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT p.trial.stimulus.side.MIDDLE],0,p);



%------------------------------------------------------------------%
%display stats at end of trial
function cleanUpandSave(p)
tic
disp('----------------------------------')
disp(['Trialno: ' num2str(p.trial.pldaps.iTrial)])
disp(['Condition: ' num2str(p.trial.stimulus.displacement*p.trial.stimulus.rotation)])
%show reward amount
if p.trial.pldaps.draw.reward.show
    pds.behavior.reward.showReward(p,{'S1';'S2'})
end

% disp(['C: ' num2str(p.trialMem.stats.val)])
% disp(['N: ' num2str(p.trialMem.stats.count.Ntrial)])
% disp(['P: ' num2str(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100)])



