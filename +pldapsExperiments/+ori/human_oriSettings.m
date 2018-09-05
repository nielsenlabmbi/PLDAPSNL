function s = human_oriSettings
% turn saving off
% s.pldaps.nosave = 1;
%set reward amounts
s. behavior.   reward. amount = [0.02 0.07 0.07];
s.behavior.reward.pulseFreq = 3;
s.behavior.reward.pulseInt = 0.2;
s.behavior.reward.amountDelta = 0.01;
s. behavior.reward. manualAmount = 0.05;
%set viewing parameters
s.stimulus.baseline = 0.5;
s.stimulus.lickdelay = 1.5;
s.stimulus.forceCorrect_delay = 0.75;
s.stimulus.duration.ITI = 1;
s.stimulus.stimON = 0.2;
s.stimulus.waitTime = 0.2;
s.stimulus.trialdur = 300;

%set instructive trials
s.stimulus.fracInstruct = 0;
%s.stimulus.fracInstructTrue = [1 0];

%set orientation and offsets
s.stimulus.offsets = {15};
s.stimulus.angle = 45;
s.stimulus.sf = 1;
s.stimulus.range = 121;
s.stimulus.runtype = 'pseudo';
s.stimulus.fullField =zeros(1,length(s.stimulus.offsets));
%set viewing parameters
s.stimulus.baseline = 0.2;
s.stimulus.trialdur = 300;

s.stimulus.radius=20; %stimulus radius in deg
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.6*s.stimulus.radius; %switch from open mask to exponential function



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
% % 
% %%% Debugging settings

%turn adc channels off
s.datapixx.useAsPorts = 0;
s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;

% turn saving off
s.pldaps.nosave = 1;