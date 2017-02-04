function basicTest(p,state)

%use normal functionality in states
pldapsDefaultTrialFunction(p,state);

%add functions to particular states
switch state
    case p.trial.pldaps.trialStates.frameDraw
        if p.conditions{p.trial.pldaps.iTrial}.color==0 
            Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.stimColor1,[500 500 900 900]);
            %Screen('FillRect',p.trial.display.ptr,[255 0 0],[100 100 500 500]);
        else
            Screen('FillRect',p.trial.display.ptr,p.trial.stimulus.stimColor2,[500 500 900 900]);
            %Screen('FillRect',p.trial.display.ptr,[0 255 0],[100 100 500 500]);
        end
        
    case p.trial.pldaps.trialStates.frameFlip;
        if p.trial.iFrame == p.trial.pldaps.maxFrames
            p.trial.flagNextTrial=true;
        end
end