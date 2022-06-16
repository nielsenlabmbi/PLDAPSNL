function sinusoidalnoise_trial_free(p,state)


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
            Screen(p.trial.display.ptr, 'FillRect', 0)
        elseif p.trial.state==p.trial.stimulus.states.STIMON || p.trial.state==p.trial.stimulus.states.INCORRECT

            p.trial.stimulus.frameI=p.trial.stimulus.frameI+1;
            frameIdx=mod(p.trial.stimulus.frameI,p.trial.stimulus.framesPerMovie)+1;
            load(['movie' num2str(p.trial.stimulus.movieId) '.mat']);
            DegPerPix = p.trial.display.dWidth/p.trial.display.pWidth;
            PixPerDeg = 1/DegPerPix;
            normalsize = round(p.trial.stimulus.dotSize*PixPerDeg);
            ferretsize = round(p.trial.stimulus.ferretdotSize*PixPerDeg);
            p.trial.stimulus.dotSizePix(1:size(coordvec, 1)) = ferretsize;
            p.trial.stimulus.dotSizePix(size(coordvec,1) + 1: size(p.trial.stimulus.dotpos,1)) = normalsize;
            Screen('DrawDots', p.trial.display.ptr, squeeze(p.trial.stimulus.dotpos(:,:,frameIdx)'),...
                p.trial.stimulus.dotSizePix, [1 1 1], ...
                [p.trial.display.pWidth/2 p.trial.display.pHeight/2],1);
            
        end
     
        
      
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        cleanUpandSave(p);
        
end

 

%% -------------------------------------------------------------------%
%check port status and set events accordingly
function p=checkState(p)

activePort=find(p.trial.ports.status==1);


switch p.trial.state
    case p.trial.stimulus.states.START %trial started
        
        if p.trial.led.state==0
            %turn LED on
            pds.LED.LEDOn(p);
            pds.LED.AnyLEDOn(p,23);
            p.trial.led.state=1;
            %note timepoint
            p.trial.stimulus.timeTrialLedOn = p.trial.ttime;
            p.trial.stimulus.frameTrialLedOn = p.trial.iFrame;
            %send trigger pulse to camera
            if p.trial.camera.use 
                pds.behavcam.triggercam(p,1);
                p.trial.stimulus.timeCamOn = p.trial.ttime;
                p.trial.stimulus.frameCamOn = p.trial.iFrame;
            end
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
            p.trial.state=p.trial.stimulus.states.STIMON;
        end
        
    case p.trial.stimulus.states.STIMON %stimulus shown; port selected in response
        %check whether any port chosen
        if ismember(activePort, [p.trial.stimulus.port.MIDDLE p.trial.stimulus.port.LEFT p.trial.stimulus.port.RIGHT])
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
                else
                    amount=p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.MIDDLE);
                    pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.MIDDLE);
                end
                
                %advance state
                p.trial.state=p.trial.stimulus.states.CORRECT;
            else
                %play tone
                pds.audio.playDatapixxAudio(p,'breakfix');
                
                %advance state
                p.trial.state=p.trial.stimulus.states.INCORRECT;
            end
        end
        
    case p.trial.stimulus.states.CORRECT %correct port selected for stimulus
        %wait for ITI
        if p.trial.ttime > p.trial.stimulus.timeTrialFirstResp + p.trial.stimulus.duration.ITI
            %trial done - note time
            p.trial.stimulus.timeTrialFinish = p.trial.ttime;
            p.trial.stimulus.frameTrialFinish = p.trial.iFrame;
            
            %advance state, mark as correct trial and flag next trial
            p.trial.state=p.trial.stimulus.states.TRIALCOMPLETE;
            p.trial.pldaps.goodtrial = 1;
            p.trial.flagNextTrial = true;
        end
        
    case p.trial.stimulus.states.INCORRECT %incorrect port selected for stimulus
        if p.trial.stimulus.forceCorrect == 1 %must give correct response before ending trial            
            %check whether any port chosen
            if ismember(activePort, [p.trial.stimulus.port.MIDDLE p.trial.stimulus.port.LEFT p.trial.stimulus.port.RIGHT])
                %check whether correct port chosen
                correct=checkPortChoice(activePort,p);                
                if correct==1 %now has chosen correct port
                    %note time
                    p.trial.stimulus.timeTrialFinalResp = p.trial.ttime;
                    p.trial.stimulus.frameTrialFinalResp = p.trial.iFrame;
                    pds.LED.AnyLEDOff(p,23);
                    
                    if activePort==p.trial.stimulus.port.LEFT
                        amount=p.trial.behavior.reward.propAmtIncorrect*p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.LEFT);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.LEFT);
                    elseif activePort==p.trial.stimulus.port.RIGHT
                        amount=p.trial.behavior.reward.propAmtIncorrect*p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.RIGHT);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.RIGHT);
                    else
                        amount=p.trial.behavior.reward.propAmtIncorrect*p.trial.behavior.reward.amount(p.trial.stimulus.rewardIdx.MIDDLE);
                        pds.behavior.reward.give(p,amount,p.trial.behavior.reward.channel.MIDDLE);
                    end
                    
                    %advance state
                    p.trial.state=p.trial.stimulus.states.FINALRESP;
                
                end
            end
                
        else %incorrect responses end trial immediately
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

        

        
%% ------------------------------------------------------------------%
%setup trial parameters, prep stimulus as far as possible
function p=trialSetup(p)

%we are implementing the graziano style (spiral space) optic flow pattern
%here, with noise that is random in direction, but not speed (each dot
%keeps its speed and direction throughout its lifetime)

if isfield(p.trial,'masktxtr')
    Screen('Close',p.trial.masktxtr);
end
p.trial.masktxtr=[];

if isfield(p.trial,'gtxtr')
    Screen('Close',p.trial.gtxtr)
end
p.trial.gtxtr=[];

%get side for condition
switch p.conditions{p.trial.pldaps.iTrial}.side
    case 1
        p.trial.side=p.trial.stimulus.side.LEFT;
    case 2
        p.trial.side=p.trial.stimulus.side.RIGHT;
    case 3
        p.trial.side=p.trial.stimulus.side.MIDDLE;
end

% set up stimulus
DegPerPix = p.trial.display.dWidth/p.trial.display.pWidth;
PixPerDeg = 1/DegPerPix;

%fixed parameters
%dot size
%just changed to lower size
p.trial.stimulus.dotSizePix = round(p.trial.stimulus.dotSize*PixPerDeg) ;

%direction
p.trial.stimulus.direction = p.conditions{p.trial.pldaps.iTrial}.direction;

%movie id
p.trial.stimulus.movieId = p.conditions{p.trial.pldaps.iTrial}.movieId;

%speed : keeping this silent for now
%p.trial.stimulus.speed = p.conditions{p.trial.pldaps.iTrial}.speed;

%phase_coherence

p.trial.stimulus.phase_coherence = p.conditions{p.trial.pldaps.iTrial}.phase_coherence;

%load movie - generates coordVec
load(['movie' num2str(p.trial.stimulus.movieId) '.mat']);

% trying to choose framerate
p.trial.stimulus.framesPerMovie = size(coordvec, 3);

%dot lifetime
p.trial.stimulus.dot_lifetime = p.trial.stimulus.framesPerMovie;

%number dots
p.trial.stimulus.nrDots = p.conditions{p.trial.pldaps.iTrial}.nrDots;



coordvec(:, 2, :) = coordvec(:, 2, :) .* p.trial.stimulus.dotSizePix;
coordvec(:, 1, :) = coordvec(:, 1, :) .* p.trial.stimulus.dotSizePix;



%**** 100% coherence means all dots are signal, i.e they don't move
%**** 0% coherence means all dots are not moving




% 100% would have the signal value, which is 100% no dots moving
% 20% would have the signal value, which is 20% no dots move

% *nothing is corresponding to global motion at this time
% *directoin calculations don't matter at this time
dot_lifetime = p.trial.stimulus.dot_lifetime;
%*** cordvec basis
herey = squeeze(coordvec(:, 2, :))';
herex = squeeze(coordvec(:,1,:))';

frames = size(herex, 1)*100;

countercellx = zeros(size(coordvec,1), frames);
countercelly = zeros(size(coordvec, 1), frames);
for j = 1:size(coordvec,3):frames
    countercellx(1:end, j:j+(size(coordvec, 3)-1)) = herex';
    countercelly(1:end, j:j+(size(coordvec, 3)-1)) = herey';
end


Xdis = diff(countercellx(:, :)');
Ydis = diff(countercelly(:, :)');

%***initialize random dots
%the bounds will correspond to psychtoolbox bounds
nrDots = p.trial.stimulus.nrDots;
maxi = max(max(max(coordvec)));
mini = min(min(min(coordvec)));
%randdotvec = rand(2, nrDots)'.*1980 - (1980/2);
randdotvec(:, 1) = -1000 + (1000 - (-1000)).*rand(1, nrDots)';
randdotvec(:, 2) = -980 + (1000 - (-1000)).*rand(1, nrDots)';

%*** initialize noise vector
coherence = p.trial.stimulus.phase_coherence;
nrSignal = round(nrDots*coherence);
noisevec = zeros(nrDots, 2);
noisevec(1:nrSignal, 1) = 1; %1 = signal 0 = noise
%the remainder noise will move w/ a random movement vector
noisevec(:, 2) = randi(size(coordvec, 1), 1, nrDots);

%idx = 0, these are the noise
%idx = 0, these are the values that will move

%*** don't need directions for now

%*** initialize lifetime

if dot_lifetime >0
    lifetime = randi(dot_lifetime, nrDots, 1);
end


%this is the building vector
%once complete, its size should be [dots x frames]
dotposx = randdotvec(:, 1);
dotposy = randdotvec(:, 2);

% countercell = zeros(2, frames);
% for j = 1:size(coordvec,3):frames
%     countercell(1, j:j+(size(coordvec, 3)-1)) = coordvec(:, 1, :);
%     countercell(2, j:j+(size(coordvec, 3)-1)) = coordvec(:, 2, :);
% end


for counter = 2:frames
    randdotvec(:, 1) = randdotvec(:, 1) + (Xdis(counter-1, noisevec(:, 2)))';
    randdotvec(:, 2) = randdotvec(:, 2) + (Ydis(counter-1, noisevec(:, 2)))';
    
    %     also need to translate in the X direction
    %      the signal dots that are supposed to move
    %for now, it will move w/ predefined direction
    ind = find(noisevec(:, 1) == 1);
    
    if p.trial.stimulus.direction==180   
        idea = find(randdotvec(ind, 1) >= 1200);
        for herewego = 1:length(idea)
            randdotvec(ind(idea(herewego)), 1) = -980 + (980 - (-980)).*rand(1, 1);
        end
        idea = find(randdotvec(ind, 1) <= -1200);
        for herewego = 1:length(idea)
            randdotvec(ind(idea(herewego)), 1) = -980 + (980 - (-980)).*rand(1, 1);
        end
        randdotvec(ind, 1) = randdotvec(ind, 1) + (1980 /(size(coordvec,3)));

    elseif p.trial.stimulus.direction==0   
        idea = find(randdotvec(ind, 1) >= 1200);
        for herewego = 1:length(idea)
            randdotvec(ind(idea(herewego)), 1) = -980 + (980 - (-980)).*rand(1, 1);
        end
        idea = find(randdotvec(ind, 1) <= -1200);
        for herewego = 1:length(idea)
            randdotvec(ind(idea(herewego)), 1) = -980 + (980 - (-980)).*rand(1, 1);
        end
        randdotvec(ind, 1) = randdotvec(ind, 1) - (1980 /(size(coordvec,3)));
    end    

    if dot_lifetime > 0
        idx = find(lifetime == 0);
        lifetime(idx) = randi(frames, length(idx), 1);
        randdotvec(idx, :) = -980 + (980 - (-980)).*rand(2, length(idx))';
        newbag(idx, 1) = rand(length(idx),1);

        if newbag(idx, 1) <= coherence
            noisevec(idx, 1) = 1;
        elseif newbag(idx, 1) > coherence
            noisevec(idx, 1) = 0;
            noisevec(idx, 2) = randi(size(coordvec, 1), 1, length(idx));
        end
        
        lifetime = lifetime - 1;
    end
    
    dotposx(:, counter) = randdotvec(:, 1);
    dotposy(:, counter) = randdotvec(:, 2);

end

thedot(:, 1, :) = dotposx;
thedot(:, 2, :) = dotposy;
opposing = thedot(:,1,1);
opposing = opposing(randperm(numel(opposing), ceil(length(opposing)/2)));
[diffidx, A] = find(thedot(:,1,1) == opposing');
thedot(diffidx,1,:) = thedot(diffidx,1,:) * -1;

diffcountercellx = zeros(size(coordvec,1), frames);
diffcountercelly = zeros(size(coordvec, 1), frames);
for j = 1:size(coordvec,3):frames
%     countercell(1, j:j+(size(coordvec, 3)-1)) = coordvec(:, 1, :);
%     countercell(2, j:j+(size(coordvec, 3)-1)) = coordvec(:, 2, :);
    
    diffcountercellx(1:end, j:j+(size(coordvec, 3)-1)) = squeeze(coordvec(:, 1, :));
    diffcountercelly(1:end, j:j+(size(coordvec, 3)-1)) = squeeze(coordvec(:, 2, :));
end

s = p.trial.stimulus.stretchFactor;
diffcountercellx = (s*diffcountercellx(:,:)) + ((1-s)*mean(diffcountercellx(1:end-1)));
diffcountercelly = (s*diffcountercelly(:,:)) + ((1-s)*mean(diffcountercelly(1:end-1)));

%I will change distance by making the max pixel value for count scaled by 5
count = 0;
distvec = [0, 10, 8, 6, 4, 2];
for iter = 0:5
    if p.trial.stimulus.dotdistance == 0
        for timer = 1:size(coordvec, 3)
            %count = count + (1980/(size(coordvec,3) ));
            diffcountercellx(:, timer) = diffcountercellx(:, timer) - count;
        end
    elseif p.trial.stimulus.dotdistance == iter
        for timer = 1:size(coordvec, 3)
            count = count + ( 1980 /(size(coordvec,3) * distvec(iter + 1)) );
            diffcountercellx(:, timer) = diffcountercellx(:, timer) - count;
        end
    end
end

if p.trial.stimulus.direction==180
    %coordvec(:, 1, :) = coordvec(:, 1, :) .* -1;
    %diffcountercellx = countercellx .* -1;
    diffcountercellx = diffcountercellx .* -1;
end

countercell(:, 1, :) = diffcountercellx;
countercell(:, 2, :) = diffcountercelly;

coordvec = cat(1, countercell, thedot);
%put into variable
p.trial.stimulus.dotpos=coordvec;


%initialize frame
p.trial.stimulus.frameI = 0;

%set state
p.trial.state=p.trial.stimulus.states.START;
if p.trial.camera.use;
    pds.behavcam.startcam(p);
end


%% ------------------------------------------------------------------%
%display stats at end of trial
function cleanUpandSave(p)
%stop camera and set trigger to low
pds.behavcam.stopcam(p);
pds.behavcam.triggercam(p,0);

pds.LED.AnyLEDOff(p,23); 

disp('----------------------------------')
disp(['Trialno: ' num2str(p.trial.pldaps.iTrial)])
%show reward amount
if p.trial.pldaps.draw.reward.show
    pds.behavior.reward.showReward(p,{'S';'L';'R';'M'})
end

%show stats
pds.behavior.countTrial(p,p.trial.pldaps.goodtrial);
num2str(vertcat(p.trialMem.stats.val,p.trialMem.stats.count.Ntrial,...
    p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100))

% %show stats
% pds.behavior.countTrial(p,p.trial.pldaps.goodtrial);
% disp(['C: ' num2str(p.trialMem.stats.val)])
% disp(['N: ' num2str(p.trialMem.stats.count.Ntrial)])
% disp(['P: ' num2str(p.trialMem.stats.count.correct./p.trialMem.stats.count.Ntrial*100)])

%user function test
if p.trial.userInput==1
    disp('decrement offset:')
    p.trialMem.stimulus.offset=p.trialMem.stimulus.offset+p.trial.stimulus.deltaOffset;
    disp(['offset left - ' num2str(p.trialMem.stimulus.offset(1))]);
end
if p.trial.userInput==2
    disp('increment offset:')
    p.trialMem.stimulus.offset=p.trialMem.stimulus.offset-p.trial.stimulus.deltaOffset;
    disp(['offset left - ' num2str(p.trialMem.stimulus.offset(1))]);
end
    

%%%%%%Helper functions
%% -------------------------------------------------------------------%
%check whether a particular port choice is correct
function correct=checkPortChoice(activePort,p)

correct=0;

switch p.trial.side
    case p.trial.stimulus.side.LEFT
        if activePort==p.trial.stimulus.port.LEFT
            correct=1;
        end
    case p.trial.stimulus.side.RIGHT
        if activePort==p.trial.stimulus.port.RIGHT
            correct=1;
        end
    case p.trial.stimulus.side.MIDDLE
        if activePort==p.trial.stimulus.port.MIDDLE
            correct=1;
        end
end