function s = dots_FBAA7Settings


%set reward amounts
s. behavior.   reward. amount = [0.1 0.4 0.4];
s.behavior.reward.pulseFreq = 5;
s.behavior.reward.pulseInt = 0.2;

%set orientation and offsets
s.stimulus.dotSize = 1.5;
s.stimulus.nrDots = 100;
s.stimulus.fractionBlack = 0.5;
s.stimulus.dotCoherence = 1;
s.stimulus.dotSpeed = 0.7;
s.stimulus.dotLifetime = 240;
s.stimulus.durStim = 480;
s.stimulus.frameRate = 120;

%set viewing parameters
s.stimulus.baseline = 0.2;
s.stimulus.lickdelay = 1;
s.stimulus.duration.ITI = 1.5;
s.stimulus.stimON = 0.2;
s.stimulus.waitTime = 0;

%set instructive trials
s.stimulus.fracInstruct = 1;

%set up the viewing distance
s.display.viewdist = 45; 

% %configure ports
 s.ports.use = true;
 s.ports.nports = 3;
 s.ports.movable = true;
 s.datapixx.adc.channels = [1 3 5];
 
 %turn mouse input off
s.mouse.useAsPort = 0;
s.mouse.use = 0;
% % 
% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
% 
% % turn saving off
% s.pldaps.nosave = 1;