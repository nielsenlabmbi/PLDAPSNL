function p = initialize_daq(p)

if p.trial.daq.use
    p.trial.daq.device = DaqDeviceIndex;
    if ~isempty(p.trial.daq.device)
        DaqDConfigPort(p.trial.daq.device,p.trial.daq.trigger.port,0);
        DaqDOut(p.trial.daq.device,p.trial.daq.trigger.port,0)
    end
end