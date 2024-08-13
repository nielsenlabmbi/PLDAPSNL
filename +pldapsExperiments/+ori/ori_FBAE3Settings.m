function s = ori_FBAE3Settings
% turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
s. behavior.   reward. amount = [0.02 0.07 0.08];
s.behavior.reward.amountDelta = 0.01;


%set orientation and offsets
s.stimulus.offsets = {[45]};
s.stimulus.shift = [15 -15];
s.stimulus.angle = 45;
s.stimulus.sf = 0.125;
s.stimulus.range = 121;
s.stimulus.runtype = 'pseudo';
s.stimulus.fullField = zeros(1,length(s.stimulus.offsets));
s.stimulus.t_period = 50; 
s.stimulus.stimtype = 1;

s.stimulus.radius=20; %stimulus radius in deg
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.6*s.stimulus.radius; %switch from open mask to exponential function


%set viewing parameters
s.stimulus.baseline = 0.1;
s.stimulus.lickdelay = 1.5;
s.stimulus.forceCorrect_delay = 0.5;
s.stimulus.duration.ITI = 1.7;
s.stimulus.stimON = 0.3;
s.stimulus.waitTime = 0.5;
s.stimulus.trialdur = 300;
s.stimulus.timeout = 0; 

%set instructive trials
s.stimulus.fracInstruct = 0.9; %0.5;
s.stimulus.fracInstructTrue = ones(size(s.stimulus.offsets));
s.stimulus.instructCutoff = 45;

%set up the viewing distance
s.display.viewdist = 45; 
% 

% %configure ports
 s.ports.use = true;
 s.ports.nPorts = 3;
 s.ports.movable = true;
 s.datapixx.adc.channels = [1 3 5]; %[1 3 5 10 11];
 s.datapixx.useAsEyepos = 0;
  %use din?
 s.datapixx.din.useFor.ports = 1;
 %turn mouse input off
s.mouse.useAsPort = 0;
s.mouse.use = 0;

%%% Debugging settings
% 
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