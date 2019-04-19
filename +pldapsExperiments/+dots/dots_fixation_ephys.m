function dots_fixation_ephys(p,state)

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
        if ~isfield(p.trial,'triggerState') | p.trial.triggerState ~= p.trial.trigger.states.TRIALSTART;
        % send trigger, note time
            p = pds.intan.send_intan(p,p.trial.ephys.trigger.trialstart,1); %for intan
            p.trial.TrialStartTrigger = p.trial.ttime;
            p.trial.triggerState = p.trial.trigger.states.TRIALSTART;
        end
        if p.trial.ttime > p.trial.stimulus.baseline
            %advance state
            p.trial.state = p.trial.stimulus.states.START;
            if p.trial.triggerState ~= p.trial.trigger.states.REFERENCE
                p = pds.intan.send_intan(p,p.trial.ephys.trigger.reference,1);
                p.trial.ReferenceTrigger = p.trial.ttime;
                p.trial.triggerState = p.trial.trigger.states.REFERENCE;
            end
        end
    case p.trial.stimulus.states.START 
        
        if p.trial.ttime > p.trial.stimulus.reference_baseline && p.trial.ports.position(p.trial.ports.dio.channel.MIDDLE)==0
            pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,1,p);
            if p.trial.triggerState ~=p.trial.trigger.states.SPOUTS
                p = pds.intan.send_intan(p,p.trial.ephys.trigger.spouts,1);
                p.trial.StartSpoutTrigger = p.trial.ttime;
                p.trial.triggerState = p.trial.trigger.states.SPOUTS;
            end
        end
        
        if activePort==p.trial.stimulus.port.START %start port activated
            
            %note timepoint
            p.trial.stimulus.timeTrialStartResp = p.trial.ttime;
            p.trial.stimulus.frameTrialStartResp = p.trial.iFrame;
            
            %advance state
            p.trial.state = p.trial.stimulus.states.LICKDELAY;
            p.trial.stimulus.switchVAR = 0;
            if p.trial.triggerState ~= p.trial.trigger.states.LICKDELAY
                p = pds.intan.send_intan(p,p.trial.ephys.trigger.lickdelay,1);
                p = pds.intan.send_intan(p,p.trial.ephys.trigger.reference,0);
                p.trial.StartRespTrigger = p.trial.ttime;
                p.trial.triggerState = p.trial.trigger.states.LICKDELAY;
            end
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
                if p.trial.triggerState ~= p.trial.trigger.states.WAIT;
                    p = pds.intan.send_intan(p,p.trial.ephys.trigger.lickdelay,0);
                    p = pds.intan.send_intan(p,p.trial.ephys.trigger.spouts,0);
                    p = pds.intan.send_intan(p,p.trial.ephys.trigger.wait,1);
                    p.trial.WaitTrigger = p.trial.ttime;
                    p.trial.triggerState = p.trial.trigger.states.WAIT;
                end
                end
            case 1
                p.trial.pldaps.licks = [];
            %give reward
                if p.trial.ttime > p.trial.stimulus.timeTrialFinalResp + p.trial.stimulus.lickdelay;
                if p.trial.ports.position(p.trial.ports.dio.channel.MIDDLE)==1
                    pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,0,p);
                    p = pds.intan.send_intan(p,p.trial.ephys.trigger.spouts,0); %for intan
                end
                
                p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
                p.trial.state=p.trial.stimulus.states.FINALRESP;
                p = pds.intan.send_intan(p,p.trial.ephys.trigger.lickdelay,0);
                end
            
        end
        
    case p.trial.stimulus.states.WAIT
        if p.trial.ttime > p.trial.stimulus.timeTrialWait + p.trial.stimulus.waitTime;
                p.trial.stimulus.timeTrialStimOn = p.trial.ttime;
                p.trial.state=p.trial.stimulus.states.STIMON;
                p = pds.intan.send_intan(p,p.trial.ephys.trigger.wait,0);
        end
        
    case p.trial.stimulus.states.STIMON %stimulus shown; port selected in response
         % trigger
        if p.trial.triggerState ~= p.trial.trigger.states.STIMON
            p = pds.intan.send_intan(p,p.trial.ephys.trigger.stimon,1);
            p.trial.triggerState = p.trial.trigger.states.STIMON;
            p.trial.StimOnTrigger = p.trial.ttime;
        end
         %wait to make ports available
        if p.trial.ttime > p.trial.stimulus.timeTrialStimOn + p.trial.stimulus.stimON && p.trial.ports.position(p.trial.ports.dio.channel.MIDDLE)==0
            pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,1,p);
            if p.trial.triggerState ~= p.trial.trigger.states.SPOUTS
                p = pds.intan.send_intan(p,p.trial.ephys.trigger.spouts,1);
            end
        end
        
        
        %check whether any port chosen
       if activePort==p.trial.stimulus.port.START %start port activated
            %note time
                p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
                %play tone
                pds.audio.playDatapixxAudio(p,'reward_short');
                
                %advance state
                p.trial.stimulus.switchVAR = 1;
                p.trial.state=p.trial.stimulus.states.LICKDELAY;
                p.trial.stimulus.timeResp = p.trial.ttime;
                
                if p.trial.triggerState ~= p.trial.trigger.states.LICKDELAY
                    p = pds.intan.send_intan(p,p.trial.ephys.trigger.lickdelay,1);
                    p = pds.intan.send_intan(p,p.trial.ephys.trigger.stimon,0);
                    p.trial.triggerState = p.trial.trigger.states.LICKDELAY;
                end
           
       end
  
    case p.trial.stimulus.states.FINALRESP
        %wait for ITI
        if p.trial.ttime > p.trial.stimulus.timeTrialFinalResp + p.trial.stimulus.duration.ITI 
            %trial done
            if p.trial.triggerState ~= p.trial.trigger.states.TRIALCOMPLETE
                p = pds.intan.send_intan(p,p.trial.ephys.trigger.trialstart,0);
                p.trial.triggerState = p.trial.trigger.states.TRIALCOMPLETE;
            end
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
%%
%wake daq
p = pds.daq_com.send_daq(p,0);
%set state
p.trial.state=p.trial.stimulus.states.BASELINE;

%set ports correctly
pds.ports.movePort([p.trial.ports.dio.channel.LEFT p.trial.ports.dio.channel.RIGHT p.trial.ports.dio.channel.MIDDLE],0,p);

function showStimulus(p)
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



%------------------------------------------------------------------%
%display stats at end of trial
function cleanUpandSave(p)
%display stats at end of trial
tic
disp('----------------------------------')
disp(['Trialno: ' num2str(p.trial.pldaps.iTrial)])
disp(['Condition: ' num2str(p.trial.stimulus.direction)])
disp(['Coherence: ' num2str(p.trial.stimulus.dotCoherence)])
%show reward amount
if p.trial.pldaps.draw.reward.show
    pds.behavior.reward.showReward(p,{'S1';'S2'})
end


% disp(['C: ' num2str(p.trialMem.stats.val)])
% disp(['N: ' num2str(p.trialMem.stats.count.Ntrial)])
% disp(['P: ' num2str(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100)])



