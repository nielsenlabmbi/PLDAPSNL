function newsomedots(p,state)

%%
%     Why do we split into frameStates?
%     It makes anaylis and demo easier
%     For demos, you simply replace the frameUpdate state and put in your recorded values for that frame, 
%     but call everything else as before. 
%     For analysis of complicated you probabbly do not want to draw anything, but just extract parameters you have not saved
%     (e.g. when you have many dots and do not want to save the single dot positions online). So you can skip frameDraw
%     But this requires a strict seperation of the steps to work well
%%

    %if you don't want all the pldapsDefaultTrialFucntions states to be used,
    %just call them in the states you want to use it.
    pldapsDefaultTrialFunction(p,state);
    switch state
        %trialStatespl
        case p.trial.pldaps.trialStates.trialSetup
            trialSetup(p);
        %case p.trial.pldaps.trialStates.trialPrepare
        %    trialPrepare(p);
        case p.trial.pldaps.trialStates.trialCleanUpandSave
            cleanUpandSave(p);
        
        %frameStates    
        case p.trial.pldaps.trialStates.frameUpdate
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.rKey) %toggle frame RATE view
                p.trial.pldaps.draw.framerate.show=~p.trial.pldaps.draw.framerate.show;
            end
        case p.trial.pldaps.trialStates.framePrepareDrawing;            
            %are we fixating yet, holding fixation, or was fixation broken
            checkFixation(p);
            %is the trial over (either done, or due to fixation break)
            checkTrialState(p);
            %store the eye position that was used during each frame, good
            %for replay of the stimulus
            p.trial.stimulus.eyeXYs(1:2,p.trial.iFrame)= [p.trial.eyeX-p.trial.display.pWidth/2; p.trial.eyeY-p.trial.display.pHeight/2];
            
            %which of the 5 motions states are we in?
            checkMotionState(p);
            %dots only move in motion state 3, advance currentMotionFrame
            %if so
            if(p.trial.stimulus.flagMotionState==3)
                p.trial.stimulus.currentMotionFrame=p.trial.stimulus.currentMotionFrame+1;
            end
            
            %do we adjust the stimulus offset to the current mouse postiion?
            if p.trial.stimulus.followMouse
                p.trial.stimulus.offset(:,p.trial.iFrame)=p.trial.mouse.cursorSamples(1:2,p.trial.mouse.samples)';
                p.trial.stimulus.offset(:,p.trial.iFrame)=pds.px2deg(p.trial.stimulus.offset(:,p.trial.iFrame)-p.trial.display.ctr(1:2)', p.trial.display.viewdist, p.trial.display.px2w);
            end

            %do we adjust the fixation point to the current mouse postiion?
            if p.trial.stimulus.fixationFollowsMouse
                p.trial.stimulus.fixationXY = p.trial.mouse.cursorSamples(1:2,p.trial.mouse.samples)'-p.trial.display.ctr(1:2);
            end
            
            %aperture
            if p.trial.stimulus.apertureType==0
               p.trial.stimulus.theseDots=true(1,size(p.trial.stimulus.dotsXYd,2));
            elseif p.trial.stimulus.apertureType==1 %square
               p.trial.stimulus.theseDots=all(abs(p.trial.stimulus.dotsXYd(:,:,p.trial.stimulus.currentMotionFrame)) <= p.trial.stimulus.aperture/2);
            elseif p.trial.stimulus.apertureType==2 %circle
               p.trial.stimulus.theseDots=sqrt(sum(p.trial.stimulus.dotsXYd(:,:,p.trial.stimulus.currentMotionFrame).^2)) <= p.trial.stimulus.aperture/2;
            end

        case p.trial.pldaps.trialStates.frameDraw;            
            %draw the dots
            if(p.trial.stimulus.flagMotionState>1 && p.trial.stimulus.flagMotionState<5)
                offset=diag(p.trial.stimulus.offset(:,p.trial.iFrame))*ones(2,sum(p.trial.stimulus.theseDots));
                Screen('Drawdots',  p.trial.display.ptr,  pds.deg2px(p.trial.stimulus.dotsXYd(:,p.trial.stimulus.theseDots,p.trial.stimulus.currentMotionFrame)+offset,p.trial.display.viewdist,p.trial.display.w2px), ...
                p.trial.stimulus.dotsW , p.trial.stimulus.dotsColor(:,p.trial.stimulus.theseDots), p.trial.display.ctr(1:2),2);  
            end

            %draw a fixation point
            if p.trial.stimulus.showFixationPoint
                 Screen('Drawdots',  p.trial.display.overlayptr,  p.trial.stimulus.fixationXY', ...
                    p.trial.stimulus.fixdotW , p.trial.display.clut.fixation, p.trial.display.ctr(1:2));  
            end
            
        %%these are not implemented/needed as pldapsDefaultTrialFunction
        %%handles everything we need in those
        %case p.trial.pldaps.trialStates.frameIdlePreLastDraw;
        %case p.trial.pldaps.trialStates.frameDrawTimecritical;
        %case p.trial.pldaps.trialStates.frameDrawingFinished;
        %case p.trial.pldaps.trialStates.frameIdlePostDraw;
        %case p.trial.pldaps.trialStates.frameFlip; 
            
    end
 
end


 
%%% set up all variables needed for the trial and precalculate a bit%%%
%---------------------------------------------------------------------% 
function trialSetup(p)        
        p.trial.stimulus.eyeXYs=nan(3,p.trial.pldaps.maxFrames); 
        
        %p.trial will hold all variables for this trials. Once the Trial is
        %done all changed variables will be copied to the PDS structure.

        % setup default trial values in the p.trial struct
        p.trial.stimulus.rngs.trialSeed=p.trial.stimulus.rngs.trialSeeds(p.trial.pldaps.iTrial);
        p.trial.stimulus.rngs.trialRNG=RandStream(p.trial.stimulus.randomNumberGenerater, 'seed', p.trial.stimulus.rngs.trialSeed);
        p.trial.stimulus.rngs.conditionerRNG=RandStream(p.trial.stimulus.randomNumberGenerater, 'seed',  randi(p.trial.stimulus.rngs.trialRNG,2^32, 1));
        setupRNG=p.trial.stimulus.rngs.conditionerRNG;
              
        p.trial.stimulus.fpOffset=0;
        p.trial.stimulus.frameFpEntered = Inf;
        
        
        %we'll have 5 motion states: 1: no dots shown, 2: dots on,
        %stationary, 3: dots moving, 4: dots stationary again, 5: dots of
        p.trial.stimulus.flagMotionState = 1;
        %         %%% setup timings %%%
        %startTime relative to first fixation
        cummotionStateStartTime=cumsum(p.trial.stimulus.motionStateDuration)/1000;
        p.trial.stimulus.motionStateStartFrame = ceil(cummotionStateStartTime/p.trial.display.ifi);
        p.trial.stimulus.fpOffset=max(p.trial.stimulus.fpOffset,max(cummotionStateStartTime(end,:)));
        p.trial.stimulus.currentMotionFrame=1;

        if ~isfield(p.trial.stimulus,'offset')
            if  p.trial.stimulus.followMouseAtTrialOnset ||  p.trial.stimulus.fixationFollowsMouseAtTrialOnset
                if p.trial.mouse.samples==0
                    pldapsDefaultTrialFunction(p,p.trial.pldaps.trialStates.frameUpdate);
                end
                if p.trial.stimulus.followMouseAtTrialOnset
                    p.trial.stimulus.offset=p.trial.mouse.cursorSamples(:,p.trial.mouse.samples)*ones(1,p.trial.pldaps.maxFrames);
                end
                if  p.trial.stimulus.fixationFollowsMouseAtTrialOnset
                    p.trial.stimulus.fixationXY = p.trial.mouse.cursorSamples(1:2,p.trial.mouse.samples)'-p.trial.display.ctr(1:2);
                    p.trial.stimulus.offset=p.trial.display.ctr(1:2)'*ones(1,p.trial.pldaps.maxFrames);
                end
            else
                p.trial.stimulus.offset=p.trial.display.ctr(1:2)'*ones(1,p.trial.pldaps.maxFrames);
            end
            %convert to degrees
            p.trial.stimulus.offset=pds.px2deg(p.trial.stimulus.offset-p.trial.display.ctr(1:2)'*ones(1,p.trial.pldaps.maxFrames), p.trial.display.viewdist, p.trial.display.px2w);
        end

        if length(p.trial.stimulus.offset)==2
            p.trial.stimulus.offset=diag(p.trial.stimulus.offset)*ones(2,p.trial.pldaps.maxFrames);
        end

        if ~isfield(p.trial.stimulus,'nThetas')
            p.trial.stimulus.nThetas = numel(p.trial.stimulus.thetas);
        end
        % setup dot parameters
        p.trial.stimulus.thetas    = p.trial.stimulus.thetas(randi(setupRNG,p.trial.stimulus.nThetas,[1 p.trial.stimulus.nThetas]));
        p.trial.stimulus.coherence = p.trial.stimulus.coherence(randi(setupRNG,numel(p.trial.stimulus.coherence),[1 1]));
        p.trial.stimulus.dotSpeed  = p.trial.stimulus.dotSpeed(randi(setupRNG,numel(p.trial.stimulus.dotSpeed),[1 1]));

        %create the dot positions, not that the returned number of frames can be
        %larger than the requested frame count, as the same number of
        %frames per motion pules (nThetas) is generated.
        %one could adjust the motionDurations here to make sure all
        %calculated motion frames are shown
        p.trial.stimulus.dotsXYd = newsomedots.genMTdots(p.trial.stimulus,p.trial.stimulus.motionStateStartFrame(3)-p.trial.stimulus.motionStateStartFrame(2)+1,p.trial.display.frate,setupRNG); %dots=

        p.trial.stimulus.dotsColor=p.trial.stimulus.dotColor1(:,ones(1,size(p.trial.stimulus.dotsXYd,2)));
        p.trial.stimulus.dotsColor(:,1:2:end)=p.trial.stimulus.dotColor2(:,ones(1,ceil(size(p.trial.stimulus.dotsXYd,2)/2)));
end
    
function p = cleanUpandSave(p)
        setupRNG=p.trial.stimulus.rngs.conditionerRNG;

        %remove info from unshown frames
        fn=fieldnames(p.trial.stimulus);
        for j=1:length(fn)
           if(size(p.trial.stimulus.(fn{j}),2) == p.trial.pldaps.maxFrames) %assume it's a frame variable
               p.trial.stimulus.(fn{j})(:,p.trial.iFrame:end)=[];
           end
        end
        %ane remove unshown frames from dotsXYd. One could also shift this
        %by the number of frames untill the first motion frame.
        p.trial.stimulus.dotsXYd = p.trial.stimulus.dotsXYd(:,:,1:p.trial.stimulus.currentMotionFrame);
        
        %%handle conditions
        %missing: condition could have its seed stored as field and there
        %could be an option to copy this seed to ensure identical trials
        %for now we just copy the base parameters and will not preserve the
        %seed
        thisCondition=p.conditions{p.trial.pldaps.iTrial};
        if ~p.trial.pldaps.goodtrial %need to repeat that condition
           insertPosition=randi(setupRNG,[p.trial.pldaps.iTrial+1 max(p.trial.pldaps.iTrial+1,length(p.conditions)+1)]);
           p.conditions=[p.conditions(1:insertPosition-1) thisCondition p.conditions(insertPosition:end)];
        end
        if(p.trial.pldaps.iTrial==length(p.conditions))
            p.trial.pldaps.finish=p.trial.pldaps.iTrial;
        end
        
        if p.trial.newEraSyringePump.use && p.trial.behavior.reward.iReward >1
            display(sprintf('Trial %i\tTotal reward: %.3f ml.', p.trial.pldaps.iTrial,(sum(p.trial.behavior.reward.timeReward(1:p.trial.behavior.reward.iReward-1,2)))));
%         else
%             display(sprintf('Trial %i\tTotal reward: %f ms.', p.trial.pldaps.iTrial,(sum(p.trial.behavior.reward.timeReward(2,1:p.trial.behavior.reward.iReward-1)))));
        end
    end




%%helper functions
%-------------------------------------------------------------------------%
%%% INLINE FUNCTIONS
%-------------------------------------------------------------------------%
    function held = fixationHeld(p)
        held = squarewindow(p.trial.pldaps.pass,p.trial.display.ctr(1:2)+p.trial.stimulus.fixationXY-[p.trial.eyeX p.trial.eyeY],p.trial.stimulus.fpWin(1),p.trial.stimulus.fpWin(2));
    end
    
% CHECK FIXATION
%---------------------------------------------------------------------%
function p = checkFixation(p)
        % WAITING FOR SUBJECT FIXATION (fp1)
        fixating=fixationHeld(p);
        if  p.trial.state == p.trial.stimulus.states.START
            if fixating && p.trial.ttime  < (p.trial.stimulus.preTrial+p.trial.stimulus.fixWait)
                p.trial.stimulus.colorFixDot = p.trial.display.clut.targetnull;
                p.trial.stimulus.colorFixWindow = p.trial.display.clut.window;
                p.trial.stimulus.timeFpEntered = p.trial.ttime;%GetSecs - p.trial.trstart;
                p.trial.stimulus.frameFpEntered = p.trial.iFrame;
                if p.trial.datapixx.use
                    pds.datapixx.flipBit(p.trial.event.FIXATION,p.trial.pldaps.iTrial)
                end
                p.trial.state = p.trial.stimulus.states.FPHOLD;
            elseif p.trial.ttime  > (p.trial.stimulus.preTrial+p.trial.stimulus.fixWait) 
                if p.trial.datapixx.use
                    pds.datapixx.flipBit(p.trial.event.BREAKFIX,p.trial.pldaps.iTrial)
                end
                p.trial.stimulus.timeBreakFix = p.trial.ttime;%GetSecs - p.trial.trstart;
                p.trial.state = p.trial.stimulus.states.BREAKFIX;
            end
        end
        
        % check if fixation is held
        
        %%p.trial.ttime is set by the pldaps.runTrial function before each
        %%frame state
        if p.trial.state == p.trial.stimulus.states.FPHOLD
            if fixating && (p.trial.ttime > p.trial.stimulus.timeFpEntered + p.trial.stimulus.fpOffset || p.trial.iFrame==p.trial.pldaps.maxFrames)
                p.trial.stimulus.colorFixDot    = p.trial.display.clut.bg;
                p.trial.stimulus.colorFixWindow = p.trial.display.clut.bg;
                if p.trial.datapixx.use
                    pds.datapixx.flipBit(p.trial.event.FIXATION,p.trial.pldaps.iTrial)
                end
                p.trial.ttime      = GetSecs - p.trial.trstart;
                p.trial.stimulus.timeFpOff  = p.trial.ttime;
                p.trial.stimulus.frameFpOff = p.trial.iFrame;
                p.trial.stimulus.timeComplete = p.trial.ttime;
                p.trial.state      = p.trial.stimulus.states.TRIALCOMPLETE;
            elseif ~fixating && p.trial.ttime < p.trial.stimulus.timeFpEntered + p.trial.stimulus.fpOffset
                p.trial.stimulus.colorFixDot    = p.trial.display.clut.bg;
                p.trial.stimulus.colorFixWindow = p.trial.display.clut.bg;
                if p.trial.datapixx.use
                    pds.datapixx.flipBit(p.trial.event.BREAKFIX,p.trial.pldaps.iTrial)
                end
                p.trial.stimulus.timeBreakFix = GetSecs - p.trial.trstart;
                p.trial.state = p.trial.stimulus.states.BREAKFIX;
           
            end
        end
                
    end

% CHECK MOTION
%---------------------------------------------------------------------%
function p = checkMotionState(p)
        previousState=p.trial.stimulus.flagMotionState;
        for iState=1:length(p.trial.stimulus.motionStateStartFrame)
            if p.trial.stimulus.flagMotionState == iState && p.trial.iFrame >= p.trial.stimulus.frameFpEntered + p.trial.stimulus.motionStateStartFrame(iState)       
                p.trial.stimulus.flagMotionState=p.trial.stimulus.flagMotionState+1;
            end 
        end
        
        if p.trial.stimulus.flagMotionState~=previousState
        	p.trial.ttime = GetSecs - p.trial.trstart;
            p.trial.stimulus.stimStateOnTime(p.trial.stimulus.flagMotionState)  = p.trial.ttime;
            p.trial.stimulus.stimStateOnFrame(p.trial.stimulus.flagMotionState) = p.trial.iFrame;
        end
end

% TRIAL COMPLETE? -- GIVE REWARD IF GOOD
%---------------------------------------------------------------------%
function p = checkTrialState(p)
        if p.trial.state == p.trial.stimulus.states.TRIALCOMPLETE
            p.trial.pldaps.goodtrial = 1;
            
            pds.behavior.reward.give(p);
              
            if p.trial.datapixx.use
                pds.datapixx.flipBit(p.trial.event.TRIALEND,p.trial.pldaps.iTrial);
            end
            p.trial.flagNextTrial = true;
        end
        
        if p.trial.state == p.trial.stimulus.states.BREAKFIX
            % turn off stimulus
            p.trial.stimulus.colorFixDot        = p.trial.display.clut.bg;            % fixation point 1 color
            p.trial.stimulus.colorFixWindow     = p.trial.display.clut.bg;           % fixation window color
            p.trial.pldaps.goodtrial = 0;
            p.trial.targOn = 2;
            if p.trial.sound.use && ~isnan( p.trial.stimulus.timeFpEntered) 
                PsychPortAudio('Start', p.trial.sound.breakfix, 1, [], [], GetSecs + .1);
            end
            p.trial.flagNextTrial = true;
        end
end