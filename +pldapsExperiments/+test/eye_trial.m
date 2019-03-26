function eye_trial(p,state)

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
            %Screen('DrawTexture',p.trial.display.ptr, p.trial.stimulus.initex,[],p.trial.stimulus.dstRect,p.trial.stimulus.refangle,0);
        elseif p.trial.state==p.trial.stimulus.states.STIMON 
            showStimulus(p);        
        elseif p.trial.state == p.trial.stimulus.states.WAIT
            Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.waitColor,[0 0 1920 1080]);
        end
        
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        cleanUpandSave(p);
        
end




%-------------------------------------------------------------------%
%check port status and set events accordingly
function p=checkState(p)

activePort=find(p.trial.ports.status==1);


switch p.trial.state
case p.trial.stimulus.states.START %trial RIGHTed
        
%         if p.trial.ttime > p.trial.stimulus.baseline && p.trial.ports.position(p.trial.ports.dio.channel.MIDDLE)==0
%             pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,1,p);
%         end
        
        %if activePort==p.trial.stimulus.port.START %start port activated
        if p.trial.ttime > p.trial.stimulus.baseline
            %note timepoint
            p.trial.stimulus.timeTrialStimOn = p.trial.ttime;
            p.trial.stimulus.frameTrialStimOn = p.trial.iFrame;
            
            %advance state
            p.trial.state = p.trial.stimulus.states.STIMON;
            p.trial.iFrame0 = p.trial.iFrame;
                p.trial.iFrame2 = p.trial.iFrame - p.trial.iFrame0;
%             p.trial.state = p.trial.stimulus.states.LICKDELAY;
%             p.trial.stimulus.switchVAR = 0;
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
        p.trial.iFrame2 = p.trial.iFrame - p.trial.iFrame0;
         %wait to make ports available
%         if p.trial.ttime > p.trial.stimulus.timeTrialStimOn + p.trial.stimulus.stimON && p.trial.ports.position(p.trial.ports.dio.channel.MIDDLE)==0
%             pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,1,p);
%         end
        
        
        %check whether any port chosen
%        if activePort==p.trial.stimulus.port.START %start port activated
%             %note time
%                 p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
%                 p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
%                 %play tone
%                 pds.audio.playDatapixxAudio(p,'reward_short');
%                 
%                 %advance state
%                 p.trial.stimulus.switchVAR = 1;
%                 p.trial.state=p.trial.stimulus.states.LICKDELAY;
%                 p.trial.stimulus.timeResp = p.trial.ttime;
%            
%        end
if p.trial.ttime > p.trial.stimulus.timeTrialStimOn + p.trial.stimulus.stimdur
    p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
    p.trial.state = p.trial.stimulus.states.FINALRESP;
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



%set up initialization stimulus (this could be in settings file)

p.trial.stimulus.ctr = [960 540 960 540];

p.trial.stimulus.waitColor = 1;

%set up stimulus
p.trial.stimulus.color = p.conditions{p.trial.pldaps.iTrial}.color;
%p.trial.stimulus.position=p.conditions{p.trial.pldaps.iTrial}.position;
p.trial.stimulus.frameI = 0;
p.trial.stimulus.pursuit = p.conditions{p.trial.pldaps.iTrial}.pursuit;
p.trial.stimulus.direction = p.conditions{p.trial.pldaps.iTrial}.direction;
p.trial.stimulus.size = p.conditions{p.trial.pldaps.iTrial}.size{1};
p.trial.stimulus.limits = p.conditions{p.trial.pldaps.iTrial}.limits{1};

p.trial.stimulus.iniColor= p.trial.stimulus.color;
p.trial.stimulus.iniSize = p.trial.stimulus.ctr + p.trial.stimulus.size;
%p.trial.stimulus.iniSize=[920 500 1000 580];

%set state
p.trial.state=p.trial.stimulus.states.START;

%set ports correctly
pds.ports.movePort([p.trial.ports.dio.channel.LEFT p.trial.ports.dio.channel.RIGHT p.trial.ports.dio.channel.MIDDLE],0,p);

function showStimulus(p)
if p.trial.stimulus.pursuit == 1
    if p.trial.stimulus.frameI == 0
        randpos = p.trial.stimulus.iniSize;
    else
        randpos = p.trial.stimulus.pos{p.trial.stimulus.frameI};
    end
    p.trial.stimulus.frameI = p.trial.stimulus.frameI+1;
    xproj=cos(p.trial.stimulus.direction*pi/180);
    yproj=-sin(p.trial.stimulus.direction*pi/180);
    shift = repmat([p.trial.stimulus.dFrame*xproj p.trial.stimulus.dFrame*yproj],1,2);
    randpos = randpos + shift;
    limits = p.trial.stimulus.limits;
    
    if randpos(1) > limits(1) || randpos(2) > limits(2) || randpos(3) > limits(3) || randpos(4) > limits(4)
        randpos = randpos - shift;
    end
    
%     if randpos(1) < 420 || randpos(3) > 1500 || randpos(2) < 0 || randpos(4) > 1080
%         randpos = randpos - shift;
%     end
    p.trial.stimulus.pos{p.trial.stimulus.frameI} = randpos;
    Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.color,p.trial.stimulus.pos{p.trial.stimulus.frameI});
else
    %p.trial.stimulus.dFrame = 500;
    p.trial.stimulus.dFrame = (p.trial.stimulus.limits(4) - p.trial.stimulus.limits(3))/2 - unique(abs(p.trial.stimulus.size));
    p.trial.stimulus.frameI = 1;
    randpos = p.trial.stimulus.iniSize;
    xproj=cos(p.trial.stimulus.direction*pi/180);
    yproj=-sin(p.trial.stimulus.direction*pi/180);
    shift = repmat([p.trial.stimulus.dFrame*xproj p.trial.stimulus.dFrame*yproj],1,2);
    randpos = randpos + shift;

    p.trial.stimulus.pos{1} = randpos;
    p.trial.stimulus.pos{p.trial.stimulus.frameI} = randpos;
    Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.color,p.trial.stimulus.pos{p.trial.stimulus.frameI});
end

%------------------------------------------------------------------%
%display stats at end of trial
function cleanUpandSave(p)
tic
disp('----------------------------------')
disp(['Trialno: ' num2str(p.trial.pldaps.iTrial)])
disp(['Condition: ' num2str(p.trial.stimulus.direction)])
%show reward amount
if p.trial.pldaps.draw.reward.show
    pds.behavior.reward.showReward(p,{'S1';'S2'})
end

% disp(['C: ' num2str(p.trialMem.stats.val)])
% disp(['N: ' num2str(p.trialMem.stats.count.Ntrial)])
% disp(['P: ' num2str(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100)])



