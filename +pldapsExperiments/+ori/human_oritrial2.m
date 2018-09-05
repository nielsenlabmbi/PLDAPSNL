function human_oritrial2(p,state)

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
        
        if p.trial.ttime > p.trial.stimulus.baseline
            p.trial.stimulus.timeTrialWait = p.trial.ttime;
            p.trial.state=p.trial.stimulus.states.WAIT;
            
        end
        
    case p.trial.stimulus.states.WAIT
        if p.trial.ttime > p.trial.stimulus.timeTrialWait + p.trial.stimulus.waitTime;
                p.trial.stimulus.timeTrialStimOn = p.trial.ttime;
                p.trial.state=p.trial.stimulus.states.STIMON;
        end
        
    case p.trial.stimulus.states.STIMON %stimulus shown; port selected in response
        
        %check for choice
        if p.trial.userInput==1 || p.trial.userInput==2;
            
            %note time
            p.trial.stimulus.timeTrialFirstResp = p.trial.ttime;
            p.trial.stimulus.frameTrialFirstResp = p.trial.iFrame;
        
            %note response
            p.trial.stimulus.respTrial=p.trial.userInput;
            
            %check whether correct port chosen
            correct=checkPortChoice(p);
            if correct==1
                p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
                %play tone
                pds.audio.playDatapixxAudio(p,'reward_short');
                
                %advance state
                p.trial.stimulus.switchVAR = 1;
                p.trial.state=p.trial.stimulus.states.FINALRESP;
                p.trial.stimulus.timeResp = p.trial.ttime;
                %note good trial
                p.trial.pldaps.goodtrial = 1;
                p.trialMem.countCorrect = [p.trialMem.countCorrect 1];
                p.trialMem.correct = p.trialMem.correct + 1;
                
            else
                p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
                %play tone
                pds.audio.playDatapixxAudio(p,'breakfix');
                %note bad trial
                p.trial.pldaps.goodtrial = 0;
                p.trialMem.countCorrect = [p.trialMem.countCorrect 0];
                %advance state
                p.trial.state=p.trial.stimulus.states.FINALRESP;
            end
            p.trial.stimulus.timeoutFlag = 0;
            p.trialMem.Ntrial = p.trialMem.Ntrial + 1;
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
if ~isfield(p.trialMem,'Ntrial');
    p.trialMem.Ntrial = 0;
end
if ~isfield(p.trialMem,'correct');
    p.trialMem.correct = 0;
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
if ~isfield(p.trialMem,'displacement')
    p.trialMem.displacement=p.conditions{p.trial.pldaps.iTrial}.displacement;
end
p.trial.stimulus.displacement = p.trialMem.displacement;
if ~isfield(p.trialMem,'countCorrect');
    p.trialMem.countCorrect = [];
end

%set up stimulus
p.trial.stimulus.refangle = p.conditions{p.trial.pldaps.iTrial}.angle;
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
    x=linspace(-(p.trial.display.dWidth/2),p.trial.display.dWidth/2,p.trial.display.pWidth);
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

if length(p.trialMem.countCorrect) >=2
   if sum(p.trialMem.countCorrect(end-1:end)) == 0
       p.trialMem.displacement = p.trialMem.displacement + 3;
       p.trialMem.countCorrect = [];
   elseif length(p.trialMem.countCorrect) >= 3 && sum(p.trialMem.countCorrect(end-2:end)) == 3
       p.trialMem.displacement = p.trialMem.displacement - 3;
       p.trialMem.countCorrect = [];
   end
end
if isfield(p.trialMem,'displacement') && p.trialMem.displacement < 1
    p.trialMem.displacement = 0.5;
end

% %show stats
% pds.behavior.countTrial(p,p.trial.pldaps.goodtrial);
% num2str(vertcat(p.trialMem.stats.val,p.trialMem.stats.count.Ntrial,...
%     p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100))


disp(['C: ' num2str(p.trialMem.displacement)])
disp(['N: ' num2str(p.trialMem.Ntrial)])
disp(['P: ' num2str(p.trialMem.correct./p.trialMem.Ntrial*100)])



%%%%%%Helper functions
%-------------------------------------------------------------------%
%check whether a particular port choice is correct
function correct=checkPortChoice(p)

correct=0;

switch p.trial.side
    case p.trial.stimulus.side.LEFT
        if p.trial.userInput==1
            correct=1;
        end
    case p.trial.stimulus.side.RIGHT
        if p.trial.userInput==2;
            correct=1;
        end
end

