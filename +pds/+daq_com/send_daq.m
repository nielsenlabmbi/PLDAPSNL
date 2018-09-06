function p = send_daq(p,digWord)
% digWord 1 for predelay, 3 for stimulus 0 for post delay
if p.trial.daq.use && ~isempty(p.trial.daq.device)
    DaqDOut(p.trial.daq.device,p.trial.daq.trigger.port,digWord)
end