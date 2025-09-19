function s = hp_fixdots_settings_XXXX0


s. behavior.   reward. amount = [0.04 0.08 0.08];

s.stimulus.dotSize = 1.5;
s.stimulus.nrDots = 250;
s.stimulus.fractionBlack = 0;
s.stimulus.direction = [0:22.5:360];
s.stimulus.dotCoherence = 1;%[1 1 0.8 0.6 0.4 0.2];
s.stimulus.dotSpeed = 0.6;
s.stimulus.dotLifetime = 240;
s.stimulus.frameRate = 120;

s.stimulus.baseline = 2; %duration baseline in sec
s.stimulus.durStim = 5; %duration stimulus in sec
s.stimulus.duration.ITI = 1;

s.display.viewdist = 45; 

s.ports.use = true;
s.ports.nPorts = 3;
s.ports.movable = true;
s.datapixx.adc.channels = [1 3 5];
s.datapixx.din.useFor.ports = 1;

s.ephys.use = 1;

s.stimulus.cond.Ncond = length(s.stimulus.direction);


