function p = initialize_dac(p)

if p.trial.daq.use
    p.trial.daq.device = DaqDeviceIndex;
    if ~isempty(p.trial.daq.device)
        DaqDConfigPort(p.trial.daq.device,0,0);
        DaqDOut(p.trial.daq.device,0,0)
    end
end