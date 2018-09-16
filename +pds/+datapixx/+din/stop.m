function p = stop(p)

if ~p.trial.datapixx.use || isempty(p.trial.datapixx.din.channelMapping)
    return;
end

p = pds.datapixx.din.getData(p);

Datapixx('StopDinLog');
Datapixx RegWrRd;

%timing
p.trial.datapixx.din.stopDatapixxTime = Datapixx('GetTime'); %GetSecs;
p.trial.datapixx.din.stopPldapsTime = GetSecs;
[getsecs, boxsecs, confidence] = PsychDataPixx('GetPreciseTime');
p.trial.datapixx.din.stopDatapixxPreciseTime(1:3) = [getsecs, boxsecs, confidence];