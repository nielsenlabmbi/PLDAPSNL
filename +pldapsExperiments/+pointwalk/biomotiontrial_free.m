function biomotiontrial_free(p,state)


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
        %framescale = 220 / p.trial.stimulus.framesPerMovie;
        %framescale will always be max frame of movielist (220/this can be
        %set in settings) / divided by the coordvec length which
        %corresponds with the frame in that particular movie
        if p.trial.state==p.trial.stimulus.states.START
            Screen(p.trial.display.ptr, 'FillRect', 0)
        elseif p.trial.state==p.trial.stimulus.states.STIMON || p.trial.state==p.trial.stimulus.states.INCORRECT
            %where change starts
         
            %origonal start
            p.trial.stimulus.frameI=p.trial.stimulus.frameI+1;
            frameIdx=mod(p.trial.stimulus.frameI,p.trial.stimulus.framesPerMovie)+1;
            Screen('DrawDots', p.trial.display.ptr, squeeze(p.trial.stimulus.dotpos(:,:,frameIdx)'),...
                p.trial.stimulus.dotSizePix, [1 1 1], ...
                [p.trial.display.pWidth/2 p.trial.display.pHeight/2],1);
        end
     
        
%     case p.trial.pldaps.trialStates.frameDraw
%         
%         %framescale will always be max frame of movielist (220/this can be
%         %set in settings) / divided by the coordvec length which
%         %corresponds with the frame in that particular movie
%         if p.trial.state==p.trial.stimulus.states.START
%             Screen(p.trial.display.ptr, 'FillRect', 0)
%         elseif p.trial.state==p.trial.stimulus.states.STIMON || p.trial.state==p.trial.stimulus.states.INCORRECT
%             framescale = ceil(220 / p.trial.stimulus.framesPerMovie);
%             frameII = 1;
%         
%             if frameII <= framescale
%                 p.trial.stimulus.frameI=p.trial.stimulus.frameI+1;                  
%                 frameIdx=mod(p.trial.stimulus.frameI,p.trial.stimulus.framesPerMovie)+1;
%                 Screen('DrawDots', p.trial.display.ptr, squeeze(p.trial.stimulus.dotpos(:,:,frameIdx)'),...
%                     p.trial.stimulus.dotSizePix, [1 1 1], ...
%                     [p.trial.display.pWidth/2 p.trial.display.pHeight/2],1);
% 
%                 frameII = frameII + 1;
%             end
%                 if frameII <= framescale
%                     Screen('DrawDots', p.trial.display.ptr, squeeze(p.trial.stimulus.dotpos(:,:,frameIdx)'),...
%                         p.trial.stimulus.dotSizePix, [1 1 1], ...
%                         [p.trial.display.pWidth/2 p.trial.display.pHeight/2],1);
%                     frameII = frameII + 1;
%                 end
%                     if frameII <= framescale
%                         Screen('DrawDots', p.trial.display.ptr, squeeze(p.trial.stimulus.dotpos(:,:,frameIdx)'),...
%                             p.trial.stimulus.dotSizePix, [1 1 1], ...
%                             [p.trial.display.pWidth/2 p.trial.display.pHeight/2],1);
%                         frameII = frameII + 1;
%                     end
%                         if frameII <= framescale
%                         Screen('DrawDots', p.trial.display.ptr, squeeze(p.trial.stimulus.dotpos(:,:,frameIdx)'),...
%                             p.trial.stimulus.dotSizePix, [1 1 1], ...
%                             [p.trial.display.pWidth/2 p.trial.display.pHeight/2],1);
%                         end
%                     
%                 
%            
%             p.trial.stimulus.frameI=p.trial.stimulus.frameI+1;                  
%             frameIdx=mod(p.trial.stimulus.frameI,p.trial.stimulus.framesPerMovie)+1;
%             Screen('DrawDots', p.trial.display.ptr, squeeze(p.trial.stimulus.dotpos(:,:,frameIdx)'),...
%                 p.trial.stimulus.dotSizePix, [1 1 1], ...
%                 [p.trial.display.pWidth/2 p.trial.display.pHeight/2],1);
%             
%         
% 
%            
% %             frameIdx=mod(p.trial.stimulus.frameI,p.trial.stimulus.framesPerMovie)+1;
% %             Screen('DrawDots', p.trial.display.ptr, squeeze(p.trial.stimulus.dotpos(:,:,frameIdx)'),...
% %                 p.trial.stimulus.dotSizePix, [1 1 1], ...
% %                 [p.trial.display.pWidth/2 p.trial.display.pHeight/2],1);
%         end
        
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

%dotdistance

p.trial.stimulus.dotdistance = p.conditions{p.trial.pldaps.iTrial}.dotdistance;

%load movie - generates coordVec
load(['movie' num2str(p.trial.stimulus.movieId) '.mat']);

% trying to choose framerate
p.trial.stimulus.framesPerMovie = size(coordvec, 3);

%don't need later
% if size(coordvec, 3) <= 100
%     coordvec = cat(3, coordvec, coordvec+coordvec, coordvec+coordvec+coordvec);
% end

%flip directions as necessary, scaling etc



coordvec(:, 2, :) = coordvec(:, 2, :) .* 100;
coordvec(:, 1, :) = coordvec(:, 1, :) .* 100;


%i'm changing distance in the loops, it used to be speed: faster by 1.2 or
%slowed by 2
%this might be repurposed later to replace the 'lock' feature wherever it
%is

%I will change distance by making the max pixel value for count scaled by 5
count = 0;
distvec = [0, 10, 8, 6, 4, 2];
for iter = 0:5
    if p.trial.stimulus.dotdistance == 0
        for timer = 1:size(coordvec, 3)
            %count = count + (1980/(size(coordvec,3) ));
            coordvec(:, 1, timer) = coordvec(:, 1, timer) - count;
        end
    elseif p.trial.stimulus.dotdistance == iter
        for timer = 1:size(coordvec, 3)
            count = count + ( 1980 /(size(coordvec,3) * distvec(iter + 1)) );
            coordvec(:, 1, timer) = coordvec(:, 1, timer) - count;
        end
    end
end
        
%for speed        
%     elseif p.trial.stimulus.speed==2
%         for timer = 1:size(coordvec, 3)
%             count = count + (1980/(size(coordvec,3) * 2));
%             coordvec(:, 1, timer) = coordvec(:, 1, timer) - count;
%         end

%for distance
%distvec = [0, 396, 792, 1188, 1584, 1980];
% if p.trial.stimulus.dotdistance == iter
%         for timer = 1:size(coordvec, 3)
%             count = count + (distvec((iter + 1))/(size(coordvec,3) ));
%             coordvec(:, 1, timer) = coordvec(:, 1, timer) - count;
%         end
%     end
% end

if p.trial.stimulus.direction==180
    coordvec(:, 1, :) = coordvec(:, 1, :) .* -1;
end

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