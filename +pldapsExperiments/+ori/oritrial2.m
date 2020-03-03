function oritrial2(p,state)

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
            %Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.iniColor,p.trial.stimulus.iniSize);
            Screen('DrawTexture',p.trial.display.ptr, p.trial.stimulus.initex,[],p.trial.stimulus.dstRect,p.trial.stimulus.refangle,0);
        elseif p.trial.state==p.trial.stimulus.states.STIMON || p.trial.state==p.trial.stimulus.states.INCORRECT
            Screen('DrawTexture',p.trial.display.ptr,p.trial.gratTex,[],p.trial.gratPos,0);
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
    case p.trial.stimulus.states.START %trial RIGHTed
        
%         if p.trial.led.state==0
%             %turn LED on
%             pds.LED.LEDOn(p);
%             p.trial.led.state=1;
%             %note timepoint
%             p.trial.stimulus.timeTrialLedOn = p.trial.ttime;
%             p.trial.stimulus.frameTrialLedOn = p.trial.iFrame;
%         end
        
        if p.trial.ttime > p.trial.stimulus.baseline
            p.trial.stimulus.timeTrialWait = p.trial.ttime;
            p.trial.state=p.trial.stimulus.states.WAIT;
            
        end
        
    case p.trial.stimulus.states.LICKDELAY
        switch p.trial.stimulus.switchVAR
            case 1
                p.trial.pldaps.licks = [];
            %give reward
                if p.trial.ttime < p.trial.stimulus.timeResp + p.trial.stimulus.lickdelay & activePort==p.trial.stimulus.port.RIGHT...
                        & activePort == p.trial.side %active port is the correct port
                    %deliver reward
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
                    
                    %note timepoint
                    p.trial.pldaps.licks = [p.trial.pldaps.licks p.trial.ttime];
                end
                
                if p.trial.ttime < p.trial.stimulus.timeResp + p.trial.stimulus.lickdelay & activePort==p.trial.stimulus.port.LEFT...
                        & activePort == p.trial.side %active port is the correct port
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
                p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
                p.trial.state=p.trial.stimulus.states.FINALRESP;
                end
            
            case 2
            
            if p.trial.ttime > p.trial.stimulus.timeResp + p.trial.stimulus.forceCorrect_delay;
                if any(p.trial.ports.position)
                    pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT],0,p);
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
        end
        
    case p.trial.stimulus.states.STIMON %stimulus shown; port selected in response
        
         %wait to make ports available
        if p.trial.ttime > p.trial.stimulus.timeTrialStimOn + p.trial.stimulus.stimON && p.trial.ports.position(p.trial.stimulus.side.LEFT)==0 && p.trial.ports.position(p.trial.stimulus.side.RIGHT)==0;
            pds.ports.movePort(p.trial.side,1,p);
            if isfield(p.trial,'fracInstructTrue')
                if p.trial.fracInstructTrue | p.trial.stimulus.displacement > 40;
                    
                    pds.ports.movePort(1 + mod(p.trial.side,2),p.trial.ports.moveBool,p);
                else
                    
                    pds.ports.movePort(1+mod(p.trial.side,2),1,p);
                    p.trial.ports.moveBool = 1;
                end
                    
            else
            %if p.trial.stimulus.displacement >20;
                pds.ports.movePort(1 + mod(p.trial.side,2),p.trial.ports.moveBool,p);
            %else
              %  pds.ports.movePort(1+mod(p.trial.side,2),1,p);
               % p.trial.ports.moveBool = 1;
            %end
            %             pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT],1,p);
            end
        end
        
        
        %check whether any port chosen
        if activePort==p.trial.stimulus.port.LEFT | activePort==p.trial.stimulus.port.RIGHT
            %note time
            p.trial.stimulus.timeTrialFirstResp = p.trial.ttime;
            p.trial.stimulus.frameTrialFirstResp = p.trial.iFrame;
        
            %note response
            p.trial.stimulus.respTrial=p.trial.ports.status;
            
            %check whether correct port chosen
            correct=checkPortChoice(activePort,p);
            if correct==1
                p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
                %play tone
                pds.audio.playDatapixxAudio(p,'reward_short');
                %retract incorrect spout, deliver reward
                if p.trial.side==p.trial.stimulus.side.LEFT
                    
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                    if p.trial.ports.position(p.trial.stimulus.side.RIGHT)==1
                        pds.ports.movePort(p.trial.stimulus.side.RIGHT,0,p);
                    end
                end
                if p.trial.side==p.trial.stimulus.side.RIGHT
                    
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
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
                %note bad trial
                p.trial.pldaps.goodtrial = 0;
                %advance state
                p.trial.state=p.trial.stimulus.states.INCORRECT;
            end
            p.trial.stimulus.timeoutFlag = 0;
        end
        
        %if ferret does not make a choice after trial duration, advance
        %state
        if p.trial.ttime > p.trial.stimulus.timeTrialStimOn + p.trial.stimulus.trialdur;
             p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
             p.trial.state = p.trial.stimulus.states.FINALRESP;
             p.trial.stimulus.timeoutFlag = 1;
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
                    %give (small) reward                
                    if p.trial.ttime < p.trial.stimulus.timeResp + p.trial.stimulus.forceCorrect_delay & p.trial.side==p.trial.stimulus.port.RIGHT 
                        %deliver reward
                        amount=0.06;
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
                        
                    end
                    
                    if p.trial.ttime < p.trial.stimulus.timeResp + p.trial.stimulus.forceCorrect_delay & activePort==p.trial.stimulus.port.LEFT 
                        %deliver reward
                        amount=0.06;
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
if p.conditions{p.trial.pldaps.iTrial}.side==2
    p.trial.side=p.trial.stimulus.side.LEFT;
else
    p.trial.side=p.trial.stimulus.side.RIGHT;
end

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

%determine which spouts are presented when stimulus is presented
%p.trial.ports.moveBool = double(rand > p.trial.stimulus.fracInstruct);

if isfield(p.conditions{p.trial.pldaps.iTrial},'fracInstructTrue')
    p.trial.fracInstructTrue = p.conditions{p.trial.pldaps.iTrial}.fracInstructTrue;
end

%set up initialization stimulus (this could be in settings file)
p.trial.stimulus.iniColor=0;
inibar = 248*ones(10,1);
p.trial.stimulus.initex = Screen('MakeTexture',p.trial.display.ptr,inibar);
[s1,s2] = size(inibar);
dstRect = [0 0 s1 s2].*40;
p.trial.stimulus.dstRect = CenterRectOnPointd(dstRect,960,540);
% p.trial.stimulus.iniSize=[910 490 1010 590];

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
%make grating
    %DegPerPix = p.trial.display.dWidth/p.trial.display.pWidth;
    %PixPerDeg = 1/DegPerPix;

    % GET GRATING SPECIFICATIONS
%     nCycles = 24*p.trial.stimulus.sf;
%     DegPerCyc = 1/p.trial.stimulus.sf;
    ApertureDeg = 2*p.trial.stimulus.radius;%DegPerCyc*nCycles;

    % CREATE A MESHGRID THE SIZE OF THE GRATING
    x=linspace(-(p.trial.display.dWidth/2),p.trial.display.dWidth/2,p.trial.display.pWidth)-p.trial.stimulus.shift(p.trial.side);
    y=linspace(-(p.trial.display.dHeight/2),p.trial.display.dHeight/2,p.trial.display.pHeight);
    [x,y] = meshgrid(x,y);


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


%set state
p.trial.state=p.trial.stimulus.states.START;

%set ports correctly
pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT p.trial.stimulus.side.MIDDLE],0,p);










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
    p.trialMem.count = 0;
    disp('decreased fracInstruct')
end
if p.trial.userInput==2
    p.trialMem.fracInstruct = p.trial.stimulus.fracInstruct + 0.1;
    p.trialMem.count = 0;
    disp('increased fracInstruct')
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
        end
    case p.trial.stimulus.side.RIGHT
        if activePort==p.trial.stimulus.side.RIGHT
            correct=1;
        end
end

