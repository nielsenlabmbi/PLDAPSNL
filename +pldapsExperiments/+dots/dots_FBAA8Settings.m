function s = dots_FBAA8Settings

%set reward amounts
s. behavior.   reward. amount = [0.01 0.04 0.08];
s.behavior.reward.pulseFreq = 3;
s.behavior.reward.pulseInt = 0.2;
s.behavior.reward.amountDelta = 0.01;
s. behavior.reward. manualAmount = 0.05;

s.stimulus.dotSize = 1.5;
s.stimulus.nrDots = 250;
s.stimulus.fractionBlack = 0.5;
s.stimulus.dotCoherence = 1;%[1 1 0.8 0.6 0.4 0.2];
s.stimulus.dotSpeed = 0.6;
s.stimulus.dotLifetime = [240];
s.stimulus.durStim = 480;
s.stimulus.frameRate = 120;
s.stimulus.direction = [0 180];

%set viewing parameterses
s.stimulus.baseline = 0.1;
s.stimulus.lickdelay = 1.7;
s.stimulus.forceCorrect_delay = 0.75;
s.stimulus.duration.ITI = 2;
s.stimulus.stimON = 0.3;
s.stimulus.waitTime = 0.8;
s.stimulus.trialdur = 30;
s.stimulus.timeout = 3; 

%set instructive trials
s.stimulus.fracInstruct = 0.5;

%set up the viewing distance
s.display.viewdist = 45; 

% %configure ports
 s.ports.use = true;
 s.ports.nports = 3;
 s.ports.movable = true;
 s.datapixx.adc.channels = [1 3 5];
 s.datapixx.useAsEyepos = 1;
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