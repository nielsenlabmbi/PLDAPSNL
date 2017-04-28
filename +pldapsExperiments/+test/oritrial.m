function oritrial(p,state)

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
            Screen('DrawTexture',p.trial.display.ptr,p.trial.gratTex,[],p.trial.gratPos,0);
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
        
        if p.trial.led.state==0
            %turn LED on
            pds.LED.LEDOn(p);
            p.trial.led.state=1;
            %note timepoint
            p.trial.stimulus.timeTrialLedOn = p.trial.ttime;
            p.trial.stimulus.frameTrialLedOn = p.trial.iFrame;
        end
        
        if p.trial.ttime > p.trial.stimulus.baseline && p.trial.ports.position(p.trial.ports.dio.channel.MIDDLE)==0
             pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,1,p);
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
            p.trial.state = p.trial.stimulus.states.LICKDELAY;
            p.trial.stimulus.switchVAR = 0;
            
        end
        
    case p.trial.stimulus.states.LICKDELAY
        switch p.trial.stimulus.switchVAR
            case 0
            
            amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.START);
            
            if p.trial.ttime > p.trial.stimulus.timeTrialStartResp + p.trial.stimulus.lickdelay ;
                if p.trial.ports.position(p.trial.ports.dio.channel.MIDDLE)==1
                    pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,0,p);
                end
                p.trial.stimulus.timeTrialWait = p.trial.ttime;
                p.trial.state=p.trial.stimulus.states.WAIT;
            end
            
            case 1
            
            if p.trial.ttime > p.trial.stimulus.timeResp + p.trial.stimulus.lickdelay;
                if any(p.trial.ports.position)
                    pds.ports.movePort([p.trial.ports.dio.channel.LEFT p.trial.ports.dio.channel.RIGHT],0,p);
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
        if p.trial.ttime > p.trial.stimulus.timeTrialStimOn + p.trial.stimulus.stimON && p.trial.ports.position(p.trial.ports.dio.channel.LEFT)==0 && p.trial.ports.position(p.trial.ports.dio.channel.RIGHT)==0;
            pds.ports.movePort(p.trial.side,1,p);
            pds.ports.movePort(1 + mod(p.trial.side,2),p.trial.ports.moveBool,p);
%             pds.ports.movePort([p.trial.ports.dio.channel.LEFT p.trial.ports.dio.channel.RIGHT],1,p);
        end
        
        %check whether any port chosen
        if activePort==p.trial.stimulus.port.LEFT | activePort==p.trial.stimulus.port.RIGHT
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
                end
                
                %retract incorrect spout
                if p.trial.side==p.trial.stimulus.side.LEFT
                    if p.trial.ports.position(p.trial.ports.dio.channel.RIGHT)==1
                        pds.ports.movePort(p.trial.ports.dio.channel.RIGHT,0,p);
                    end
                end
                if p.trial.side==p.trial.stimulus.side.RIGHT
                    if p.trial.ports.position(p.trial.ports.dio.channel.LEFT)==1
                        pds.ports.movePort(p.trial.ports.dio.channel.LEFT,0,p);
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
                
                %advance state
                p.trial.state=p.trial.stimulus.states.INCORRECT;
            end
        end
        
%     case p.trial.stimulus.states.CORRECT %correct port selected for stimulus
%         %wait for ITI
%         if p.trial.ttime > p.trial.stimulus.timeTrialFirstResp + p.trial.stimulus.duration.ITI
%             %trial done - note time
%             p.trial.stimulus.timeTrialFinish = p.trial.ttime;
%             p.trial.stimulus.frameTrialFinish = p.trial.iFrame;
%             
%             %advance state, mark as correct trial and flag next trial
%             p.trial.state=p.trial.stimulus.states.TRIALCOMPLETE;
%             p.trial.pldaps.goodtrial = 1;
%             p.trial.flagNextTrial = true;
%         end
        
    case p.trial.stimulus.states.INCORRECT %incorrect port selected for stimulus
        if p.trial.stimulus.forceCorrect == 1 %must give correct response before ending trial
            
            %retract incorrect spout
            if p.trial.side==p.trial.stimulus.side.LEFT
                if p.trial.ports.position(p.trial.ports.dio.channel.RIGHT)==1
                    pds.ports.movePort(p.trial.ports.dio.channel.RIGHT,0,p);
                end
            end
            if p.trial.side==p.trial.stimulus.side.RIGHT
                if p.trial.ports.position(p.trial.ports.dio.channel.LEFT)==1
                    pds.ports.movePort(p.trial.ports.dio.channel.LEFT,0,p);
                end
            end
            
            %check whether any port chosen
            if activePort==p.trial.stimulus.port.LEFT | activePort==p.trial.stimulus.port.RIGHT
                %check whether correct port chosen
                correct=checkPortChoice(activePort,p);                
                if correct==1 %now has chosen correct port
                    
                    %give (small) reward
                    if activePort==p.trial.stimulus.port.LEFT
                        amount=p.trial.behavior.reward.propAmtIncorrect*p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                    elseif activePort==p.trial.stimulus.port.RIGHT
                        amount=p.trial.behavior.reward.propAmtIncorrect*p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
                    end
                    
                    %advance state
                    p.trial.stimulus.timeResp = p.trial.ttime;
                    p.trial.stimulus.switchVAR = 1;
                    p.trial.state=p.trial.stimulus.states.LICKDELAY;
                
                end
            end
                
        else %incorrect responses end trial immediately
            %retract spouts
            if any(p.trial.ports.position)
                pds.ports.movePort([p.trial.ports.dio.channel.LEFT p.trial.ports.dio.channel.RIGHT],0);
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

%determine which spouts are presented when stimulus is presented
p.trial.ports.moveBool = double(rand > p.trial.stimulus.fracInstruct);

%set up initialization stimulus (this could be in settings file)
p.trial.stimulus.iniColor=1;
p.trial.stimulus.iniSize=[910 490 1010 590];
p.trial.stimulus.waitColor = 0.5;

%set up stimulus
p.trial.stimulus.displacement=p.conditions{p.trial.pldaps.iTrial}.displacement;
p.trial.stimulus.rotation = p.conditions{p.trial.pldaps.iTrial}.rotation;
p.trial.stimulus.sf = p.conditions{p.trial.pldaps.iTrial}.sf;
p.trial.stimulus.angle = p.conditions{p.trial.pldaps.iTrial}.angle + p.trial.stimulus.rotation*p.trial.stimulus.displacement;
p.trial.stimulus.phase = p.conditions{p.trial.pldaps.iTrial}.phase;
p.trial.stimulus.range = p.conditions{p.trial.pldaps.iTrial}.range;

%make grating
    %DegPerPix = p.trial.display.dWidth/p.trial.display.pWidth;
    %PixPerDeg = 1/DegPerPix;

    % GET GRATING SPECIFICATIONS
    nCycles = 24*p.trial.stimulus.sf;
    DegPerCyc = 1/p.trial.stimulus.sf;
    ApertureDeg = DegPerCyc*nCycles;

    % CREATE A MESHGRID THE SIZE OF THE GRATING
    x=linspace(-(p.trial.display.dWidth/2),p.trial.display.dWidth/2,p.trial.display.pWidth);
    y=linspace(-(p.trial.display.dHeight/2),p.trial.display.dHeight/2,p.trial.display.pHeight);
    [x,y] = meshgrid(x,y);


    % Transform to account for orientation
    sdom=x*cos(p.trial.stimulus.angle*pi/180)-y*sin(p.trial.stimulus.angle*pi/180);

    % GRATING
    sdom=sdom*p.trial.stimulus.sf*2*pi;
    sdom1=cos(sdom-p.trial.stimulus.phase*pi/180);

    % CREATE A GAUSSIAN TO SMOOTH THE OUTER 10% OF THE GRATING
    r = sqrt(x.^2 + y.^2);
    sigmaDeg = ApertureDeg/16.5;
    MaskLimit=.6*ApertureDeg/2;
    maskdom = exp(-.5*(r-MaskLimit).^2/sigmaDeg.^2);
    maskdom(r<MaskLimit) = 1;
    grating = sdom1.*maskdom;

    % TRANSFER THE GRATING INTO AN IMAGE
    grating = round(grating*p.trial.stimulus.range) + 127;

    p.trial.gratTex = Screen('MakeTexture',p.trial.display.ptr,grating);
    p.trial.gratPos = [0 0 1920 1080];

%set state
p.trial.state=p.trial.stimulus.states.START;

%set ports correctly
pds.ports.movePort([p.trial.ports.dio.channel.LEFT p.trial.ports.dio.channel.RIGHT p.trial.ports.dio.channel.MIDDLE],0,p);










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

%+/- fract instruct
if p.trial.userInput==1
    p.trial.stimulus.fracInstruct = p.trial.stimulus.fracInstruct - 0.05;
    disp('decreased fracInstruct')
end
if p.trial.userInput==2
    p.trial.stimulus.fracInstruct = p.trial.stimulus.fracInstruct + 0.05;
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
            p.trial.stimulus.switchVAR = 1;
        end
    case p.trial.stimulus.side.RIGHT
        if activePort==p.trial.stimulus.side.RIGHT
            correct=1;
            p.trial.stimulus.switchVAR = 2; 
        end
end

