%% frameFlip
%---------------------------------------------------------------------%

function frameFlip(s)

s.timing.flipTimes(:,s.iFrame) = deal(Screen('Flip', s.display.ptr,0));

if s.display.movie.create
    frameDuration=1;
    Screen('AddFrameToMovie', s.display.ptr,[],[],s.display.movie.ptr, frameDuration);
end

%did the background color change?
%we're doing it here to make sure we don't overwrite anything
%but this tyically causes a one frame delay until it's applied
%i.e. when it's set in frame n, it changes when frame n+1 flips
%otherwise we could trust users not to draw before
%frameDraw, but we'll check again at frameDraw to be sure
if any(s.pldaps.lastBgColor~=s.display.bgColor)
    Screen('FillRect', s.display.ptr,s.display.bgColor);
    s.pldaps.lastBgColor = s.display.bgColor;
end

if(s.datapixx.use && s.display.useOverlay)
    Screen('FillRect', s.display.overlayptr,0);
end

s.stimulus.timeLastFrame = s.timing.flipTimes(1,s.iFrame)-s.trstart;
s.framePreLastDrawIdleCount=0;
s.framePostLastDrawIdleCount=0;
end %frameFlip

