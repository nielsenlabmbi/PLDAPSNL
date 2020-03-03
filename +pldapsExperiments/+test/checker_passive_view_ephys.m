function checker_passive_view_ephys(p,state)

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
    case p.trial.stimulus.states.START %trial RIGHTed
        
%         if p.trial.ttime > p.trial.stimulus.baseline && p.trial.ports.position(p.trial.stimulus.side.MIDDLE)==0
%             pds.ports.movePort(p.trial.stimulus.side.MIDDLE,1,p);
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
                if p.trial.ports.position(p.trial.stimulus.side.MIDDLE)==1
                    pds.ports.movePort(p.trial.stimulus.side.MIDDLE,0,p);
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
                if p.trial.ports.position(p.trial.stimulus.side.MIDDLE)==1
                    pds.ports.movePort(p.trial.stimulus.side.MIDDLE,0,p);
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
%         if p.trial.ttime > p.trial.stimulus.timeTrialStimOn + p.trial.stimulus.stimON && p.trial.ports.position(p.trial.stimulus.side.MIDDLE)==0
%             pds.ports.movePort(p.trial.stimulus.side.MIDDLE,1,p);
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

p.trial.stimulus.iniColor=1;
p.trial.stimulus.iniSize=[910 490 1010 590];

p.trial.stimulus.waitColor = 0.5;

%set up initialization stimulus (this could be in settings file)
%shorthand to make rest easier
%%

xN = round(p.trial.display.pWidth);
yN = round(p.trial.display.pHeight);
bN = deg2pixNL(p,p.trial.stimulus.block_size,'round',2);

%generate texture
rN = ceil(yN/bN);
pN = ceil(xN/bN);

black = zeros(bN);
white = ones(bN);
tile = [black white; white black];
board = repmat(tile,rN,pN);

p.trial.gtxtr(1) = Screen('MakeTexture',p.trial.display.ptr, board,[],[],2);
board = mod(board+1,2);
p.trial.gtxtr(2) = Screen('MakeTexture',p.trial.display.ptr, board, [],[],2);

p.trial.polarity = 1;

%set state
p.trial.state=p.trial.stimulus.states.START;

%set ports correctly
%pds.ports.movePort([p.trial.stimulus.side.LEFT p.trial.stimulus.side.RIGHT p.trial.stimulus.side.MIDDLE],0,p);

function showStimulus(p)

    
    %set polarity
    if mod(p.trial.iFrame2,p.trial.stimulus.t_period)==0
        p.trial.polarity=3-p.trial.polarity;
    end
    
    %draw checkerboard
    Screen('DrawTexture', p.trial.display.ptr, p.trial.gtxtr(p.trial.polarity), [], [0 0 1920 1080]);


%------------------------------------------------------------------%
%display stats at end of trial
function cleanUpandSave(p)
tic
disp('----------------------------------')
disp(['Trialno: ' num2str(p.trial.pldaps.iTrial)])
%show reward amount
if p.trial.pldaps.draw.reward.show
    pds.behavior.reward.showReward(p,{'S1';'S2'})
end

% disp(['C: ' num2str(p.trialMem.stats.val)])
% disp(['N: ' num2str(p.trialMem.stats.count.Ntrial)])
% disp(['P: ' num2str(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100)])



