function opticFlowTrial(p,state)

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
            showStimulus(p);
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
            
        end
        
    case p.trial.stimulus.states.LICKDELAY
            if p.trial.ttime > p.trial.stimulus.timeTrialStartResp + p.trial.stimulus.lickdelay ;
                if p.trial.ports.position(p.trial.ports.dio.channel.MIDDLE)==1
                    pds.ports.movePort(p.trial.ports.dio.channel.MIDDLE,0,p);
                end
                p.trial.stimulus.timeTrialWait = p.trial.ttime;
                p.trial.state=p.trial.stimulus.states.WAIT;
            end
            
        
    case p.trial.stimulus.states.WAIT
        if p.trial.ttime > p.trial.stimulus.timeTrialWait + p.trial.stimulus.waitTime;
                p.trial.stimulus.timeTrialStimOn = p.trial.ttime;
                p.trial.state=p.trial.stimulus.states.STIMON;
        end
        
    case p.trial.stimulus.states.STIMON %stimulus shown; port selected in respons
        
            if p.trial.ttime > p.trial.stimulus.timeTrialStimOn + p.trial.stimulus.duration.ITI
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

%set up initialization stimulus (this could be in settings file)
p.trial.stimulus.iniColor=1;
p.trial.stimulus.iniSize=[910 490 1010 590];
p.trial.stimulus.waitColor = 0.5;

%% set up stimulus

%stimuli: basic set described in Duffy & Wurtz 91 - translation, circular
%and radial motion; also added random condition
%same idea: speed sets speed for translational, radial and random stimuli and random; for the circular
%motion, it sets the average speed
%all stimuli are programmed as circles -> large enough circles make
%fullfield stimuli
%reason: wrap around for the radial and circular condition are difficult to get right otherwise
%four types of translation: up, down, left, right
%two types of rotation: cw, ccw
%two types of radial: expansion, contraction
%this uses the classic way of generating noise dots, in which they are
%simply moved to some other location on the screen. i.e. noise dots have
%different speeds and directions, unlike the brownian type motion used for
%noise dots in the RDK stimulus

fps = p.trial.stimulus.frameRate;     % frames per second
%initialize frame
p.trial.stimulus.frameI = 0;

%stimulus radius in pixels
deg2px = p.trial.display.pWidth/p.trial.display.dWidth;
stimRadiusPx = p.trial.stimulus.stimRadius*round(deg2px);

%dot displacement
deltaFrame = p.trial.stimulus.speedDots*deg2px/fps;
%central displacement
deltaXpx = p.conditions{p.trial.pldaps.iTrial}.deltaXY(1)*deg2px/fps;
deltaYpx = p.conditions{p.trial.pldaps.iTrial}.deltaXY(2)*def2px/fps;

%figure out how many dots
stimArea=p.trial.stimulus.stimRadius^2*4;  %we initialize all stimuli on a square, so use that to compute area
nrDots=round(p.trial.stimulus.dotDensity*stimArea/fps); %this is the number of dots in each frame


%initialize random number generate to time of date
s = RandStream.create('mrg32k3a','NumStreams',1,'Seed',datenum(date)+1000*(randi(10))+(randi(23))+p.trialMem.stats.count.Ntrial(1));


%initialize dot positions
%initialization using polar coordinates leads to 'clumping' in the center, so
%need to initialize on a square no matter which condition
randpos=rand(s,2,nrDots); %this gives numbers between 0 and 1

xypos(1,:)=(randpos(1,:)-0.5)*stimRadiusPx*2; %now we have between -stimsize and +stimsize
xypos(2,:)=(randpos(2,:)-0.5)*stimRadiusPx*2;

%initialize signal/noise vector; 1 indicates signal, 0 indicates noise
nrSignal=round(nrDots*p.trial.stimulus.dotCoherence/100);
noisevec=zeros(nrDots,1);
noisevec(1:nrSignal)=1;

%initialize lifetime vector - between 1 and dotLifetimte
if p.trial.stimulus.dotLifetime>0
    randlife=randi(s,p.trial.dotLifetime,nrDots,1);
    lifetime=randlife;
end

%figure out how many frames - we use the first and the last frame to be
%shown in the pre and postdelay, so only stimulus duration matters here
nrFrames=ceil(p.trial.stimulus.stim_time*fps);

p.trial.stimulus.dotFrame={};
tmpFrame={};

for i=1:nrFrames
    xypos(1,:)= xypos(1,:) - deltaXpx*(i-1); %now we have between -stimsize and +stimsize
    xypos(2,:)= xypos(2,:) - deltaYpx*(i-1);
    %check lifetime (unless inf)
    if p.trial.stimulus.dotLifetime>0
        idx=find(lifetime==0);
        [~,rad]= cart2pol(xypos(1,idx),xypos(2,idx));
        thrand=rand(s,1,length(idx))*2*pi;
        [xypos(1,idx),xypos(2,idx)]=pol2cart(thrand,rad);
        lifetime=lifetime-1;
        lifetime(idx)=p.trial.dotLifetime;
    end
    
    
    %generate new positions - this is different for noise and signal pixels
    %the algorithm we use here is the one described in Britten et al, 1993
    %first determine which pixels are signal or noise
    noiseid=noisevec(randperm(s,nrDots));
    %noise dots are randomly placed somewhere; again, because of the
    %clumping when randomizing the radius, we only randomize the phase for the radial stimuli, not the
    %radius
    idx=find(noiseid==0);
    [~,rad]=cart2pol(xypos(1,idx),xypos(2,idx));
    thrand=rand(s,1,length(idx))*2*pi;
    [xypos(1,idx),xypos(2,idx)]=pol2cart(thrand,rad);
    
    
    idx=find(noiseid==1);
    %radial pattern
    %radial pattern needs to be solved differently than the other
    %patterns because of wrap around; problem: in the expanding
    %stimulus, every deltaFrame ring loses dots (because the
    %smaller rings have less dots in them); this can be fixed by
    %redistributing the dots that come out of the largest ring in
    %every frame; if the stimulus contracts, every ring has more
    %dots in the subsequent frame than before -> would need to
    %redistribute them somehow.... easier to just run an expanding
    %stimulus backwards
    
    [th,rad]=cart2pol(xypos(1,idx),xypos(2,idx));
    
    rad=rad+deltaFrame;
    
    %wrap around
    %logic behind this computation: a ring of width deltaFrame,
    %from r to r+deltaFrame, contains (ignoring the density)
    %nrdots = pi(r+deltaFrame)^2-pi r^2= 2pi r deltaFrame+piDeltaFrame^2
    %based on this, every frame each of the deltaFrame rings
    %loses 2 pi deltaFrame^2 dots; the only exception is the
    %central ring, which only loses pi deltaFrame^2 dots
    %so to correctly fill in dots, we need to adjust the
    %probability of assigning the radius for the central ring
    %and all other rings; likelihood for a dot needing to be
    %placed at the center is 1/(2*(nrbins-1)+1, which ends up
    %being 1/(2*stimRadiusPx/deltaFrame -1)
    
    
    %find out of bounds dots
    idx2=find(rad>stimRadiusPx);
    
    %determine how many dots should fall into the center based
    %on probability distribution described above
    probinner=1/(2*stimRadiusPx/deltaFrame-1);
    rinout=rand(s,1,length(idx2));
    nrinner=length(find(rinout<probinner));
    
    %now get new locations (random radius within limit, random
    %theta)
    tmprad=[];
    tmprad(1:nrinner)=rand(s,1,nrinner)*deltaFrame;
    tmprad(nrinner+1:length(idx2))=rand(s,1,length(idx2)-nrinner)*...
        (stimRadiusPx-deltaFrame)+deltaFrame;
    
    tmpth=rand(s,1,length(idx2))*2*pi;
    
    %put back into original matrix
    rad(idx2)=tmprad;
    th(idx2)=tmpth;
    
    %done with wrap around and moving, generate xypos for next
    %frame
    [xtemp,ytemp]=pol2cart(th,rad);
    xypos(1,idx)=xtemp;
    xypos(2,idx)=ytemp;
    
    %make sure to only keep dots inside the stimulus radius
    [~,rad]=cart2pol(xypos(1,:),xypos(2,:));
    idx=find(rad<stimRadiusPx);
    
    if p.trial.stimulus.stimDir==-1 %we still need to reverse the order for the contracting stimuli
        tmpFrame{i}=xypos(:,idx);
    else
        p.trial.stimulus.dotFrame{i}=xypos(:,idx);
    end
    
end
p.trial.stimulus.nrFrames = nrFrames;
p.trial.stimulus.sizeDotsPx = p.trial.stimulus.sizeDots*deg2px;

if p.trial.stimulus.stimDir==-1
    for i=1:nrFrames
        p.trial.stimulus.dotFrame{i}=tmpFrame{nrFrames-i+1};
    end
end

%%

%set state
p.trial.state=p.trial.stimulus.states.START;

%set ports correctly
pds.ports.movePort([p.trial.ports.dio.channel.LEFT p.trial.ports.dio.channel.RIGHT p.trial.ports.dio.channel.MIDDLE],0,p);

%show stimulus - handles rotation and movement of grating
function showStimulus(p)

p.trial.stimulus.frameI=p.trial.stimulus.frameI+1;
if p.trial.stimulus.frameI<=p.trial.stimulus.nrFrames
    
    Screen('DrawDots', p.trial.display.ptr, p.trial.stimulus.dotFrame{p.trial.stimulus.frameI}, p.trial.stimulus.sizeDotsPx, [1 1 1],...
        [p.trial.stimulus.x_pos p.trial.stimulus.y_pos], p.trial.stimulus.dotType,1);

end


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

%show stats
% pds.behavior.countTrial(p,p.trial.pldaps.goodtrial);
% num2str(vertcat(p.trialMem.stats.val,p.trialMem.stats.count.Ntrial,...
%     p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100))


% disp(['C: ' num2str(p.trialMem.stats.val)])
% disp(['N: ' num2str(p.trialMem.stats.count.Ntrial)])
% disp(['P: ' num2str(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100)])


