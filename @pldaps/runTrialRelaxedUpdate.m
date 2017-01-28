function p = runTrialRelaxedUpdate(p)
%runTrial    runs a single Trial by calling the function defined in 
%            p.trial.pldaps.trialFunction through different states
%
% 03/2013 jly   Wrote hyperflow
% 03/2014 jk    Used jly's code to get the PLDAPS structure and frame it into a class
%               might change to ASYNC buffer flipping. but won't for now.

    %the trialFunctionHandle
    tfh=str2func(p.trial.pldaps.trialFunction);
    
    %trial states that are not in a frame are negative, just to allow both
    %to be more independent
    p.trial.pldaps.trialStates.trialSetup=-1;
    p.trial.pldaps.trialStates.trialPrepare=-2;
    p.trial.pldaps.trialStates.trialCleanUpandSave=-3;
    
    %ok, what are the options?
    %we'll make them states
    %is called once after the last frame is done (or even before)
    %get current eyepostion, curser position or keypresses 
    p.trial.pldaps.trialStates.frameUpdate=1;
    %here you can prepare all drawing, e.g. have the dots move
    %if you need to update to the latest e.g. eyeposition
    %you can still do that later, this could be all expected heavy
    %calculations
    p.trial.pldaps.trialStates.framePrepareDrawing=2; 
    %once you know you've calculated the final image, draw it
    p.trial.pldaps.trialStates.frameDraw=3;
    %
    p.trial.pldaps.trialStates.frameIdlePreLastDraw=4;
    %if there is something that needs updating. here is a fucntion to do it
    %as late as possible
    p.trial.pldaps.trialStates.frameDrawTimecritical=5;
    %if this function is not used, drawingFinished will be called after
    %frameDraw is done, otherwise drawingFinished will not be called
    p.trial.pldaps.trialStates.frameDrawingFinished=6;

    %this function gets called once everything got drawn, until it's time
    %to expect (and do) the flip
    p.trial.pldaps.trialStates.frameIdlePostDraw=7;
    %do the flip (or when async) record the time 
    p.trial.pldaps.trialStates.frameFlip=8;
    
    p.trial.currentFrameState=1;    
    
    tfh(p, p.trial.pldaps.trialStates.trialSetup);
    
%     timeNeeded(p.trial.pldaps.trialStates.frameUpdate)=0.5;
%     timeNeeded(p.trial.pldaps.trialStates.framePrepareDrawing)=2;
%     timeNeeded(p.trial.pldaps.trialStates.frameDraw)=2;
%     timeNeeded(p.trial.pldaps.trialStates.frameIdlePreLastDraw)=2;
%     timeNeeded(p.trial.pldaps.trialStates.frameDrawTimecritical)=0.5;
%     timeNeeded(p.trial.pldaps.trialStates.frameDrawingFinished)=2;
%     timeNeeded(p.trial.pldaps.trialStates.frameIdlePostDraw)=0.5;
%     timeNeeded(p.trial.pldaps.trialStates.frameFlip)=5;
%     timeNeeded=timeNeeded/1000;%convert to seconds

    %switch to high priority mode
    if p.trial.pldaps.maxPriority
        oldPriority=Priority;
        maxPriority=MaxPriority('GetSecs');
        if oldPriority < maxPriority
                Priority(maxPriority);
        end
    end

    %will be called just before the trial starts for time critical calls to
    %start data aquisition
    tfh(p, p.trial.pldaps.trialStates.trialPrepare);

    p.trial.framePreLastDrawIdleCount=0;
    p.trial.framePostLastDrawIdleCount=0;

    %update and prepare for frame 1.
    p.trial.nextFrameTime = p.trial.stimulus.timeLastFrame+p.trial.display.ifi;
    tfh(p, p.trial.pldaps.trialStates.frameUpdate);    
    setTimeAndFrameState(p,p.trial.pldaps.trialStates.framePrepareDrawing)
    tfh(p, p.trial.pldaps.trialStates.framePrepareDrawing);
    setTimeAndFrameState(p,p.trial.pldaps.trialStates.frameDraw);  

    %%% MAIN WHILE LOOP %%%
    %-------------------------------------------------------------------------%
    while ~p.trial.flagNextTrial && p.trial.pldaps.quit == 0
        %go through one frame by calling tfh with the different states.
        %Save the times each state is finished.

        p.trial.nextFrameTime = p.trial.stimulus.timeLastFrame+p.trial.display.ifi;
        
        %time of the estimated next flip
%         setTimeAndFrameState(p,p.trial.pldaps.trialStates.frameDraw);
        tfh(p, p.trial.pldaps.trialStates.frameDraw);
        setTimeAndFrameState(p,p.trial.pldaps.trialStates.frameDrawingFinished);
        
        tfh(p, p.trial.pldaps.trialStates.frameDrawingFinished);
        setTimeAndFrameState(p,p.trial.pldaps.trialStates.frameUpdate)
        
        %this is very suboptimal, as the updating of data is not in the iFrame
        %as the drawing using the data
        
        p.trial.iFrame = p.trial.iFrame + 1;  % calculate for next frame here
        tfh(p, p.trial.pldaps.trialStates.frameUpdate);
        setTimeAndFrameState(p,p.trial.pldaps.trialStates.framePrepareDrawing)
        
        tfh(p, p.trial.pldaps.trialStates.framePrepareDrawing);
        setTimeAndFrameState(p,p.trial.pldaps.trialStates.frameFlip)
        p.trial.iFrame = p.trial.iFrame -1;  % revert to current frame
        %end of that comment
        
        tfh(p, p.trial.pldaps.trialStates.frameFlip);
        %advance to next frame
        setTimeAndFrameState(p,p.trial.pldaps.trialStates.frameDraw);           
        p.trial.iFrame = p.trial.iFrame + 1;  % update frame index
    end %while Trial running

    if p.trial.pldaps.maxPriority
        newPriority=Priority;
        if round(oldPriority) ~= round(newPriority)
            Priority(oldPriority);
        end
        if round(newPriority)<maxPriority
            warning('pldaps:runTrial','Thread priority was degraded by operating system during the trial.')
        end
    end

    tfh(p, p.trial.pldaps.trialStates.trialCleanUpandSave);

end %runTrial
    
function setTimeAndFrameState(p,state)
        p.trial.ttime = GetSecs - p.trial.trstart;
        p.trial.remainingFrameTime=p.trial.nextFrameTime-p.trial.ttime;
        p.trial.timing.frameStateChangeTimes(p.trial.currentFrameState,p.trial.iFrame)=p.trial.ttime-p.trial.nextFrameTime+p.trial.display.ifi;
        p.trial.currentFrameState=state;        
end