function s = ori_FBAA7Settings
% turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
s. behavior.   reward. amount = [0.03 0.08 0.08];
s.behavior.reward.amountDelta = 0.01;


%set orientation and offsets
s.stimulus.offsets{1} = [45];
s.stimulus.angle = 45;
s.stimulus.sf = 0.25;
s.stimulus.range = 121;
s.stimulus.runtype = 'pseudo';
s.stimulus.fullField = 1;
%set viewing parameters
s.stimulus.baseline = 0.2;
s.stimulus.trialdur = 300;

s.stimulus.radius=20; %stimulus radius in deg
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.6*s.stimulus.radius; %switch from open mask to exponential function


s.stimulus.lickdelay = 1.6;
s.stimulus.forceCorrect_delay = 0.5;
s.stimulus.duration.ITI = 1.0;
s.stimulus.stimON = 0.3;
s.stimulus.waitTime = 0.5;

%set instructive trials
s.stimulus.fracInstruct = 1;

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
% 
% %%% Debugging settings
% 
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