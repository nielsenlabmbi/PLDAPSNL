function s = plain_calibrate_settings
% turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
s. behavior.   reward. amount = [0.01 0.07 0.07];
s.behavior.reward.amountDelta = 0.01;
s.stimulus.Ntrials = 30;


%set orientation and offsets
s.stimulus.offsets = [45];
s.stimulus.angle = 45;
s.stimulus.sf = 0.25;
s.stimulus.range = 121;
s.stimulus.runtype = 'pseudo';
s.stimulus.fullField = 1;

s.stimulus.show = 0; 

%set viewing parameters
s.stimulus.baseline = 0.2;
s.stimulus.trialdur = 180;

s.stimulus.lickdelay = 1.7;
s.stimulus.forceCorrect_delay = 0.5;
s.stimulus.duration.ITI = 2;
s.stimulus.stimON = 0.3;
s.stimulus.waitTime = 0.3;

%set instructive trials
s.stimulus.fracInstruct = 1;

%set up the viewing distance
s.display.viewdist = 45; 
% % %turn saving off
 s.pldaps.nosave = 1;

% %configure ports
 s.ports.use = true;
 s.ports.nPorts = 3;
 s.ports.movable = true;
 s.datapixx.adc.channels = [1 3 5]; %[1 3 5 10 11];
 s.datapixx.useAsEyepos = 0;
 s.datapixx.din.useFor.ports = 1;
 %turn mouse input off
s.mouse.useAsPort = 0;
s.mouse.use = 0;
% 
% % 
% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% s.datapixx.din.useFor.ports = 0;
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
% 
% % turn saving off
% s.pldaps.nosave = 1;
