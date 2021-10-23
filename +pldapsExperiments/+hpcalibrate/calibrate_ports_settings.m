function s = calibrate_ports_settings
s.behavior.reward.setupID = 'fixed'; %headfixed
 s.ports.use = true;
 s.ports.nports = 3;
 s.ports.movable = true;
 s.datapixx.adc.channels = [1 3 5]; 
% %turn saving off
 s.pldaps.nosave = 1;
% s.behavior.reward.setupID = 'free'; %freely moving