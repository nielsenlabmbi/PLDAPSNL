function s = ori_FBAA8Settings
% turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
s. behavior.   reward. amount = [0.04 0.02 0.08];
s.behavior.reward.amountDelta = 0.01;


%set orientation and offsets
s.stimulus.offsets = [20];
s.stimulus.angle = 45;
s.stimulus.sf = 0.25;
s.stimulus.range = 121;
s.stimulus.runtype = 'pseudo';
s.stimulus.fullField = 1;
%set viewing parameters
s.stimulus.baseline = 0.2;

s.stimulus.lickdelay = 1.5;
s.stimulus.forceCorrect_delay = 0.5;
s.stimulus.duration.ITI = 2;
s.stimulus.stimON = 0.2;
s.stimulus.waitTime = 0.7;

%set instructive trials
s.stimulus.fracInstruct = 0.5; %0.5;

%set up the viewing distance
s.display.viewdist = 45; 
% 

% %configure ports
 s.ports.use = true;
 s.ports.nports = 3;
 s.ports.movable = true;
 s.datapixx.adc.channels = [1 3 5]; %[1 3 5 10 11];
 s.datapixx.useAsEyepos = 0;
 %turn mouse input off
s.mouse.useAsPort = 0;
s.mouse.use = 0;