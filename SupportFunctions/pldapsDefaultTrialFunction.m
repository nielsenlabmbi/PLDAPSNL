function pldapsDefaultTrialFunction(p,state)
switch state
    %frameStates
    case p.trial.pldaps.trialStates.frameUpdate
        frameUpdate(p);
    case p.trial.pldaps.trialStates.framePrepareDrawing
        %    framePrepareDrawing(p);
    case p.trial.pldaps.trialStates.frameDraw
        frameDraw(p);
    case p.trial.pldaps.trialStates.frameDrawingFinished;
        frameDrawingFinished(p);
    case p.trial.pldaps.trialStates.frameFlip;
        frameFlip(p);
        
        %trialStates
    case p.trial.pldaps.trialStates.trialSetup
        trialSetup(p);
    case p.trial.pldaps.trialStates.trialPrepare
        trialPrepare(p);
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        cleanUpandSave(p);
end
end


%% frameUpdate
%%% get inputs and check behavior%%%
%---------------------------------------------------------------------%
function frameUpdate(p)
%%TODO: add buffer for Keyboard presses, nouse position and clicks.

%Keyboard
[p.trial.keyboard.pressedQ, p.trial.keyboard.firstPressQ, firstRelease, lastPress, lastRelease]=KbQueueCheck(); % fast

if p.trial.keyboard.pressedQ
    p.trial.keyboard.samples = p.trial.keyboard.samples+1;
    p.trial.keyboard.samplesTimes(p.trial.keyboard.samples)=GetSecs;
    p.trial.keyboard.samplesFrames(p.trial.keyboard.samples)=p.trial.iFrame;
    p.trial.keyboard.pressedSamples(:,p.trial.keyboard.samples)=p.trial.keyboard.pressedQ;
    p.trial.keyboard.firstPressSamples(:,p.trial.keyboard.samples)=p.trial.keyboard.firstPressQ;
    p.trial.keyboard.firstReleaseSamples(:,p.trial.keyboard.samples)=firstRelease;
    p.trial.keyboard.lastPressSamples(:,p.trial.keyboard.samples)=lastPress;
    p.trial.keyboard.lastReleaseSamples(:,p.trial.keyboard.samples)=lastRelease;
end

if any(p.trial.keyboard.firstPressQ)
    pds.keyboard.keyboardCmd(p);
end
% get mouse/eyetracker/port data
if p.trial.mouse.use
    [cursorX,cursorY,isMouseButtonDown] = GetMouse(); % ktz - added isMouseButtonDown, 28Mar2013
    p.trial.mouse.samples = p.trial.mouse.samples+1;
    p.trial.mouse.samplesTimes(p.trial.mouse.samples)=GetSecs;
    p.trial.mouse.cursorSamples(1:2,p.trial.mouse.samples) = [cursorX;cursorY];
    p.trial.mouse.buttonPressSamples(:,p.trial.mouse.samples) = isMouseButtonDown';
    
    if(p.trial.mouse.useAsEyepos)
        if p.trial.pldaps.eyeposMovAv==1
            p.trial.eyeX = p.trial.mouse.cursorSamples(1,p.trial.mouse.samples);
            p.trial.eyeY = p.trial.mouse.cursorSamples(2,p.trial.mouse.samples);
        else
            mInds=(p.trial.mouse.samples-p.trial.pldaps.eyeposMovAv+1):p.trial.mouse.samples;
            p.trial.eyeX = mean(p.trial.mouse.cursorSamples(1,mInds));
            p.trial.eyeY = mean(p.trial.mouse.cursorSamples(2,mInds));
        end
    end
    
    if p.trial.ports.use && p.trial.mouse.useAsPort
        p.trial.ports.status = pds.ports.mouseInPort(p);
    end
end
%get analogData from Datapixx
pds.datapixx.adc.getData(p);
%get eyelink data
pds.eyelink.getQueue(p);
%get plexon spikes
%         pds.plexon.spikeserver.getSpikes(p);
end %frameUpdate



%% frameDraw
%---------------------------------------------------------------------%
function frameDraw(p)
%this holds the code to draw some stuff to the overlay (using
%switches, like the grid, the eye Position, etc

%consider moving this stuff to an earlier timepoint, to allow GPU
%to crunch on this before the real stuff gets added.

%did the background color change? Usually already applied after
%frameFlip, but make sure we're not missing anything
if any(p.trial.pldaps.lastBgColor~=p.trial.display.bgColor)
    Screen('FillRect', p.trial.display.ptr,p.trial.display.bgColor);
    p.trial.pldaps.lastBgColor = p.trial.display.bgColor;
end

if p.trial.pldaps.draw.grid.use
    Screen('DrawLines',p.trial.display.overlayptr,p.trial.pldaps.draw.grid.tick_line_matrix,1,p.trial.display.clut.window,p.trial.display.ctr(1:2));
end

%draw a history of fast inter frame intervals
if p.trial.pldaps.draw.framerate.use && p.trial.iFrame>2
    %update data
    p.trial.pldaps.draw.framerate.data=circshift(p.trial.pldaps.draw.framerate.data,-1);
    p.trial.pldaps.draw.framerate.data(end)=p.trial.timing.flipTimes(1,p.trial.iFrame-1)-p.trial.timing.flipTimes(1,p.trial.iFrame-2);
    %plot
    if p.trial.pldaps.draw.framerate.show
        %adjust y limit
        p.trial.pldaps.draw.framerate.sf.ylims=[0 max(max(p.trial.pldaps.draw.framerate.data), 2*p.trial.display.ifi)];
        %current ifi is solid black
        pds.pldaps.draw.screenPlot(p.trial.pldaps.draw.framerate.sf, p.trial.pldaps.draw.framerate.sf.xlims, [p.trial.display.ifi p.trial.display.ifi], p.trial.display.clut.blackbg, '-');
        %2 ifi reference is 5 black dots
        pds.pldaps.draw.screenPlot(p.trial.pldaps.draw.framerate.sf, p.trial.pldaps.draw.framerate.sf.xlims(2)*(0:0.25:1), ones(1,5)*2*p.trial.display.ifi, p.trial.display.clut.blackbg, '.');
        %0 ifi reference is 5 black dots
        pds.pldaps.draw.screenPlot(p.trial.pldaps.draw.framerate.sf, p.trial.pldaps.draw.framerate.sf.xlims(2)*(0:0.25:1), zeros(1,5), p.trial.display.clut.blackbg, '.');
        %data are red dots
        pds.pldaps.draw.screenPlot(p.trial.pldaps.draw.framerate.sf, 1:p.trial.pldaps.draw.framerate.nFrames, p.trial.pldaps.draw.framerate.data', p.trial.display.clut.redbg, '.');
    end
end

%draw the eyepositon to the second srceen only
%move the color and size parameters to
if p.trial.pldaps.draw.eyepos.use && p.trial.iFrame>2
    %update data
    p.trial.pldaps.draw.eyepos.acq = p.trial.datapixx.adc.dataSampleCount;
    p.trial.pldaps.draw.eyepos.dataX=circshift(p.trial.pldaps.draw.eyepos.dataX,-1);
    p.trial.pldaps.draw.eyepos.dataX(end) = mean(p.trial.datapixx.adc.eyepos(1,p.trial.pldaps.draw.eyepos.lastacq:p.trial.pldaps.draw.eyepos.acq));
    p.trial.pldaps.draw.eyepos.dataY=circshift(p.trial.pldaps.draw.eyepos.dataY,-1);
    p.trial.pldaps.draw.eyepos.dataY(end) = mean(p.trial.datapixx.adc.eyepos(2,p.trial.pldaps.draw.eyepos.lastacq:p.trial.pldaps.draw.eyepos.acq));

    if p.trial.pldaps.draw.eyepos.show
        %adjust y limit
        p.trial.pldaps.draw.eyepos.sf.ylims=[-1 1];
        p.trial.pldaps.draw.eyepos.sf2.ylims = [-2 1];
%         %current ifi is solid black
%         pds.pldaps.draw.screenPlot(p.trial.pldaps.draw.framerate.sf, p.trial.pldaps.draw.framerate.sf.xlims, [p.trial.display.ifi p.trial.display.ifi], p.trial.display.clut.blackbg, '-');
%         %2 ifi reference is 5 black dots
%         pds.pldaps.draw.screenPlot(p.trial.pldaps.draw.framerate.sf, p.trial.pldaps.draw.framerate.sf.xlims(2)*(0:0.25:1), ones(1,5)*2*p.trial.display.ifi, p.trial.display.clut.blackbg, '.');
%         %0 ifi reference is 5 black dots
%         pds.pldaps.draw.screenPlot(p.trial.pldaps.draw.framerate.sf, p.trial.pldaps.draw.framerate.sf.xlims(2)*(0:0.25:1), zeros(1,5), p.trial.display.clut.blackbg, '.');
        %data are red dots
        pds.pldaps.draw.screenPlot(p.trial.pldaps.draw.eyepos.sf, 1:p.trial.pldaps.draw.eyepos.nFrames, p.trial.pldaps.draw.eyepos.dataX', p.trial.display.clut.redbg, '.');
        pds.pldaps.draw.screenPlot(p.trial.pldaps.draw.eyepos.sf2, 1:p.trial.pldaps.draw.eyepos.nFrames, p.trial.pldaps.draw.eyepos.dataY', p.trial.display.clut.greenbg, '.');    
    end

    %Screen('Drawdots',  p.trial.display.overlayptr, [p.trial.eyeX p.trial.eyeY]', ...
     %   p.trial.stimulus.eyeW, p.trial.display.clut.eyepos, [0 0],0);
end
if p.trial.mouse.use && p.trial.pldaps.draw.cursor.use
    Screen('Drawdots',  p.trial.display.overlayptr,  p.trial.mouse.cursorSamples(1:2,p.trial.mouse.samples), ...
        p.trial.stimulus.eyeW, p.trial.display.clut.cursor, [0 0],0);
end

%draw squares to indicate response port status and position
if p.trial.ports.use && p.trial.pldaps.draw.ports.show
    pds.ports.drawPorts(p.trial.display.overlayptr,p.trial.pldaps.draw.ports.statusDisp,...
        p.trial.ports.status,p.trial.display.clut.blackbg,p.trial.display.clut.redbg);
    
    if p.trial.ports.movable
        pds.ports.drawPorts(p.trial.display.overlayptr,p.trial.pldaps.draw.ports.positionDisp,...
            p.trial.ports.position,p.trial.display.clut.blackbg,p.trial.display.clut.redbg);
    end
end


%draw photodiode
if p.trial.pldaps.draw.photodiode.use && mod(p.trial.iFrame, p.trial.pldaps.draw.photodiode.everyXFrames) == 0
    photodiodecolor = [1 1 1];
    p.trial.timing.photodiodeTimes(:,p.trial.pldaps.draw.photodiode.dataEnd) = [p.trial.ttime p.trial.iFrame];
    p.trial.pldaps.draw.photodiode.dataEnd=p.trial.pldaps.draw.photodiode.dataEnd+1;
    Screen('FillRect',  p.trial.display.ptr,photodiodecolor, p.trial.pldaps.draw.photodiode.rect');
end
end %frameDraw


%% frameDrawingFinished
%---------------------------------------------------------------------%
function frameDrawingFinished(p)
Screen('DrawingFinished', p.trial.display.ptr,0,0);
%         Screen('DrawingFinished', p.trial.display.overlayptr);
%if we're going async, we'd probably do the flip call here, right? but
%could also do it in the flip either way.
end %frameDrawingFinished


%% frameFlip
%---------------------------------------------------------------------%

function frameFlip(p)

p.trial.timing.flipTimes(:,p.trial.iFrame) = deal(Screen('Flip', p.trial.display.ptr,0));

if p.trial.display.movie.create
    frameDuration=1;
    Screen('AddFrameToMovie', p.trial.display.ptr,[],[],p.trial.display.movie.ptr, frameDuration);
end

%did the background color change?
%we're doing it here to make sure we don't overwrite anything
%but this tyically causes a one frame delay until it's applied
%i.e. when it's set in frame n, it changes when frame n+1 flips
%otherwise we could trust users not to draw before
%frameDraw, but we'll check again at frameDraw to be sure
if any(p.trial.pldaps.lastBgColor~=p.trial.display.bgColor)
    Screen('FillRect', p.trial.display.ptr,p.trial.display.bgColor);
    p.trial.pldaps.lastBgColor = p.trial.display.bgColor;
end

if(p.trial.datapixx.use && p.trial.display.useOverlay)
    Screen('FillRect', p.trial.display.overlayptr,0);
end

p.trial.stimulus.timeLastFrame = p.trial.timing.flipTimes(1,p.trial.iFrame)-p.trial.trstart;
p.trial.framePreLastDrawIdleCount=0;
p.trial.framePostLastDrawIdleCount=0;
end %frameFlip

%% trialSetup
%---------------------------------------------------------------------%
function trialSetup(p)

p.trial.timing.flipTimes= zeros(4,p.trial.pldaps.maxFrames);
p.trial.timing.frameStateChangeTimes=nan(9,p.trial.pldaps.maxFrames);

if(p.trial.pldaps.draw.photodiode.use)
    p.trial.timing.photodiodeTimes=nan(2,p.trial.pldaps.maxFrames);
    p.trial.pldaps.draw.photodiode.dataEnd=1;
end

%these are things that are specific to subunits as eyelink,
%datapixx, mouse and should probabbly be in separarte functions,
%but I have no logic/structure for that atm.

%setup analogData collection from Datapixx
pds.datapixx.adc.trialSetup(p);

%call PsychDataPixx('GetPreciseTime') to make sure the clocks stay
%synced
if p.trial.datapixx.use
    [getsecs, boxsecs, confidence] = PsychDataPixx('GetPreciseTime');
    p.trial.timing.datapixxPreciseTime(1:3) = [getsecs, boxsecs, confidence];
end

%setup a fields for the keyboard data
%         [~, firstPress]=KbQueueCheck();
p.trial.keyboard.samples = 0;
p.trial.keyboard.samplesTimes=zeros(1,round(p.trial.pldaps.maxFrames*1.1));
p.trial.keyboard.samplesFrames=zeros(1,round(p.trial.pldaps.maxFrames*1.1));
p.trial.keyboard.pressedSamples=false(1,round(p.trial.pldaps.maxFrames*1.1));
p.trial.keyboard.firstPressSamples = zeros(p.trial.keyboard.nCodes,round(p.trial.pldaps.maxFrames*1.1));
p.trial.keyboard.firstReleaseSamples = zeros(p.trial.keyboard.nCodes,round(p.trial.pldaps.maxFrames*1.1));
p.trial.keyboard.lastPressSamples = zeros(p.trial.keyboard.nCodes,round(p.trial.pldaps.maxFrames*1.1));
p.trial.keyboard.lastReleaseSamples = zeros(p.trial.keyboard.nCodes,round(p.trial.pldaps.maxFrames*1.1));

%setup a fields for the mouse data
if p.trial.mouse.use
    [~,~,isMouseButtonDown] = GetMouse();
    p.trial.mouse.cursorSamples = zeros(2,round(round(p.trial.pldaps.maxFrames*1.1)));
    p.trial.mouse.buttonPressSamples = zeros(length(isMouseButtonDown),round(round(p.trial.pldaps.maxFrames*1.1)));
    p.trial.mouse.samplesTimes=zeros(1,round(round(p.trial.pldaps.maxFrames*1.1)));
    p.trial.mouse.samples = 0;
end

%%% Eyelink Toolbox Setup %%%
%-------------------------------------------------------------------------%
% preallocate for all eye samples and event data from the eyelink
pds.eyelink.startTrial(p);

%%% Spike server
%-------------------------------------------------------------------------%
p.trial.plexon.spikeserver.spikeCount=0;
pds.plexon.spikeserver.getSpikes(p); %save all spikes that arrives in the inter trial interval


%%% prepare reward system
pds.behavior.reward.trialSetup(p);

%%% prepare to plot framerate history on screen
if p.trial.pldaps.draw.framerate.use
    p.trial.pldaps.draw.framerate.nFrames=round(p.trial.pldaps.draw.framerate.nSeconds/p.trial.display.ifi);
    p.trial.pldaps.draw.framerate.data=zeros(p.trial.pldaps.draw.framerate.nFrames,1); %holds the data
    sf.startPos=round(p.trial.display.w2px'.*p.trial.pldaps.draw.framerate.location + [p.trial.display.pWidth/2 p.trial.display.pHeight/2]);
    sf.size=p.trial.display.w2px'.*p.trial.pldaps.draw.framerate.size;
    sf.window=p.trial.display.overlayptr;
    sf.xlims=[1 p.trial.pldaps.draw.framerate.nFrames];
    sf.ylims=  [0 2*p.trial.display.ifi];
    sf.linetype='-';
    
    p.trial.pldaps.draw.framerate.sf=sf;
end

%%% prepare to plot eyepos history on screen
if p.trial.pldaps.draw.eyepos.use
    p.trial.pldaps.draw.eyepos.lastacq = 1;
    p.trial.pldaps.draw.eyepos.nFrames=round(p.trial.pldaps.draw.eyepos.nSeconds/p.trial.display.ifi);
    p.trial.pldaps.draw.eyepos.dataX=zeros(p.trial.pldaps.draw.eyepos.nFrames,1); %holds the data
    p.trial.pldaps.draw.eyepos.dataY=zeros(p.trial.pldaps.draw.eyepos.nFrames,1); %holds the data
    sf.startPos=round(p.trial.display.w2px'.*(p.trial.pldaps.draw.eyepos.location) + [p.trial.display.pWidth/2 p.trial.display.pHeight/2]);
    sf.size=p.trial.display.w2px'.*p.trial.pldaps.draw.eyepos.size;
    sf.window=p.trial.display.overlayptr;
    sf.xlims=[1 p.trial.pldaps.draw.eyepos.nFrames];
    sf.ylims=  [0 2*p.trial.display.ifi];
    sf.linetype='-';
 
    p.trial.pldaps.draw.eyepos.sf=sf;
    p.trial.pldaps.draw.eyepos.sf2 = sf;
    p.trial.pldaps.draw.eyepos.sf2.startPos = round(p.trial.display.w2px'.*(p.trial.pldaps.draw.eyepos.location + [0 3]) + [p.trial.display.pWidth/2 p.trial.display.pHeight/2]);
    
end

% set reward amount to the value the last trial finished with (unless it's
% the first trial)
if p.trial.pldaps.iTrial>1
    p.trial.behavior.reward.amount=p.trialMem.currentAmount;
end

end %trialSetup

%% trialPrepare
%---------------------------------------------------------------------%

function trialPrepare(p)

%%% setup PsychPortAudio %%%
%-------------------------------------------------------------------------%
% we use the PsychPortAudio pipeline to give auditory feedback because it
% has less timing issues than Beeper.m -- Beeper freezes flips as long as
% it is producing sound whereas PsychPortAudio loads a wav file into the
% buffer and can call it instantly without wasting much compute time.
pds.audio.clearBuffer(p)


%TODO        %do we need this?
if p.trial.datapixx.use
    Datapixx RegWrRd;
end


%%% Initalize Keyboard %%%
%-------------------------------------------------------------------------%
pds.keyboard.clearBuffer(p);

%initialize keyboard selected user function
p.trial.userInput=0;

%%% Eyelink Toolbox Setup %%%
%-------------------------------------------------------------------------%
% preallocate for all eye samples and event data from the eyelink
pds.eyelink.startTrialPrepare(p);


%%% START OF TRIAL TIMING %%
%-------------------------------------------------------------------------%
% record start of trial in Datapixx, Mac & Plexon
% each device has a separate clock

% At the beginning of each trial, strobe a unique number to the plexon
% through the Datapixx to identify each trial. Often the Stimulus display
% will be running for many trials before the recording begins so this lets
% the plexon rig sync up its first trial with whatever trial number is on
% for stimulus display.
% SYNC clocks
%TODO move into a pds.plexon.startTrial(p) file. Also just sent the data along the trialStart flax, or a  least after?
clocktime = fix(clock);
if p.trial.datapixx.use && p.trial.datapixx.useForStrobe
    for ii = 1:6
        p.trial.datapixx.unique_number_time(ii,:)=pds.datapixx.strobe(p,clocktime(ii));
    end
end
p.trial.unique_number = clocktime;    % trial identifier

%TODO move into a pds.plexon.startTrial(p) file? Or is this a generic
%datapixx thing? not really....
if p.trial.datapixx.use
    p.trial.timing.datapixxStartTime = Datapixx('Gettime');
    if p.trial.datapixx.useForStrobe
        p.trial.timing.datapixxTRIALSTART = pds.datapixx.flipBit(p,p.trial.event.TRIALSTART,p.trial.pldaps.iTrial);  % start of trial (Plexon)
    end
end


%ensure background color is correct
Screen('FillRect', p.trial.display.ptr,p.trial.display.bgColor);
p.trial.pldaps.lastBgColor = p.trial.display.bgColor;

vblTime = Screen('Flip', p.trial.display.ptr,0);
p.trial.trstart = vblTime;
p.trial.stimulus.timeLastFrame=vblTime-p.trial.trstart;

p.trial.ttime  = GetSecs - p.trial.trstart;
p.trial.timing.syncTimeDuration = p.trial.ttime;
end %trialPrepare

%% cleanUpandSave
%---------------------------------------------------------------------% 

function p = cleanUpandSave(p)
%TODO move to pds.datapixx.cleanUpandSave
[p.trial.timing.flipTimes(:,p.trial.iFrame)] = deal(Screen('Flip', p.trial.display.ptr));
if p.trial.datapixx.use
    p.trial.datapixx.datapixxstoptime = Datapixx('GetTime');
end
p.trial.trialend = GetSecs- p.trial.trstart;

%do a last frameUpdate
frameUpdate(p)

%clean up analogData collection from Datapixx
pds.datapixx.adc.cleanUpandSave(p);
if p.trial.datapixx.use && p.trial.datapixx.useForStrobe
    p.trial.timing.datapixxTRIALEND = pds.datapixx.flipBit(p,p.trial.event.TRIALEND,p.trial.pldaps.iTrial);  % start of trial (Plexon)
end

if(p.trial.pldaps.draw.photodiode.use)
    p.trial.timing.photodiodeTimes(:,p.trial.pldaps.draw.photodiode.dataEnd:end)=[];
end

%reward: save end amount
p.trialMem.currentAmount=p.trial.behavior.reward.amount;

% Flush KbQueue
KbQueueStop();
KbQueueFlush();

%will this crash when more samples where created than preallocated?
% mouse input
if p.trial.mouse.use
    p.trial.mouse.cursorSamples(:,p.trial.mouse.samples+1:end) = [];
    p.trial.mouse.buttonPressSamples(:,p.trial.mouse.samples+1:end) = [];
    p.trial.mouse.samplesTimes(:,p.trial.mouse.samples+1:end) = [];
end

p.trial.keyboard.samplesTimes(:,p.trial.keyboard.samples+1:end) = [];
p.trial.keyboard.samplesFrames(:,p.trial.keyboard.samples+1:end) = [];
p.trial.keyboard.pressedSamples(:,p.trial.keyboard.samples+1:end) = [];
p.trial.keyboard.firstPressSamples(:,p.trial.keyboard.samples+1:end) = [];
p.trial.keyboard.firstReleaseSamples(:,p.trial.keyboard.samples+1:end) = [];
p.trial.keyboard.lastPressSamples(:,p.trial.keyboard.samples+1:end) = [];
p.trial.keyboard.lastReleaseSamples(:,p.trial.keyboard.samples+1:end) = [];

%TODO move to pds.plexon.cleanUpandSave
% Get spike server spikes
%---------------------------------------------------------------------%
if p.trial.plexon.spikeserver.use
    try
        pds.plexon.spikeserver.getSpikes(p);
    catch me
        disp(me.message)
    end
end

p.trial.trialnumber   = p.trial.pldaps.iTrial;

% system timing
p.trial.timing.flipTimes      = p.trial.timing.flipTimes(:,1:p.trial.iFrame);
p.trial.timing.frameStateChangeTimes    = p.trial.timing.frameStateChangeTimes(:,1:p.trial.iFrame-1);

%TODO move to pds.eyelink.cleanUpandSave
if p.trial.eyelink.use
    [Q, rowId] = pds.eyelink.saveQueue(p);
    p.trial.eyelink.samples = Q;
    p.trial.eyelink.sampleIds = rowId; % I overwrite everytime because PDStrialTemps get saved after every trial if we for some unforseen reason ever need this for each trial
    p.trial.eyelink.events   = p.trial.eyelink.events(:,~isnan(p.trial.eyelink.events(1,:)));
end


%reward system
pds.behavior.reward.cleanUpandSave(p);

%lock trial if selected
if p.trialMem.lock==1
    disp('Trial locked!')
    thisCondition=p.conditions{p.trial.pldaps.iTrial}; 
    p.conditions=[p.conditions(1:p.trial.pldaps.iTrial) thisCondition p.conditions(p.trial.pldaps.iTrial+1:end)];    
end 

end %cleanUpandSave