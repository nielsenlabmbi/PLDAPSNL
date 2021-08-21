 case p.trial.pldaps.trialStates.frameDraw
        framescale = 220 / p.trial.stimulus.framesPerMovie;
        %framescale will always be max frame of movielist (220/this can be
        %set in settings) / divided by the coordvec length which
        %corresponds with the frame in that particular movie
        if p.trial.state==p.trial.stimulus.states.START
            Screen(p.trial.display.ptr, 'FillRect', 0)
        elseif p.trial.state==p.trial.stimulus.states.STIMON || p.trial.state==p.trial.stimulus.states.INCORRECT
            %where change starts
            
            %origonal start
            p.trial.stimulus.frameI=p.trial.stimulus.frameI+1;
            
            if p.trial.stimulus.frameI == 1
               frameII = 1;
                frameIdx=mod(p.trial.stimulus.frameI,p.trial.stimulus.framesPerMovie)+1;   
                Screen('DrawDots', p.trial.display.ptr, squeeze(p.trial.stimulus.dotpos(:,:,frameIdx)'),...
                    p.trial.stimulus.dotSizePix, [1 1 1], ...
                    [p.trial.display.pWidth/2 p.trial.display.pHeight/2],1);
                frameII = frameII + 1;
                    if frameII == framescale
                        p.trial.stimulus.frameI = p.trial.stimulus.frameI + 1;
                        frameIdx = mod(p.trial.stimulus.frameI,p.trial.stimulus.framesPerMovie)+1;
                        frameII = 1;
                    end
                    Screen('DrawDots', p.trial.display.ptr, squeeze(p.trial.stimulus.dotpos(:,:,frameIdx)'),...
                    p.trial.stimulus.dotSizePix, [1 1 1], ...
                    [p.trial.display.pWidth/2 p.trial.display.pHeight/2],1);
            end
        end
        
        
   %%
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
     