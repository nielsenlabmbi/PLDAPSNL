function s = som_FBAC2Settings

%set reward amounts
s. behavior.   reward. amount = [0.02 0.07 0.07];
% s.behavior.reward.pulseFreq = 3;
% s.behavior.reward.pulseInt = 0.2;
s.behavior.reward.amountDelta = 0.01;
s. behavior.reward. manualAmount = 0.05;

%set viewing parameters
s.stimulus.baseline = 0.2;
s.stimulus.lickdelay = 1.75;
s.stimulus.forceCorrect_delay = 0.5;
s.stimulus.duration.ITI = 1.7;
s.stimulus.stimON = 0.5;
s.stimulus.waitTime = 0.8;
s.stimulus.trialdur = 120;
s.stimulus.timeout = 0; 



% %set instructive trials
s.stimulus.fracInstruct = 1;

%set stimulus parameters
s.stimulus.curvetype=[1 2]; %convex/concave
s.stimulus.shapeid=[1 2]; %there are 2 shapes per curvature
s.stimulus.angle=[0 90 180 270];
s.stimulus.orthaxis=2; % axis orthogonal to ferret
s.stimulus.orthpos=[0 20]; %start and stop position
s.stimulus.orthrange=5; %noise range for position
s.stimulus.paraxis=1; %parallel axis
s.stimulus.parpos=15; %center of range
s.stimulus.parrange=5; %noise range for position
s.stimulus.rotaxis=3; %rotation axis
s.stimulus.rotrange=5; %noise range for rotation
s.stimulus.runtype = 'pseudo';
s.stimulus.sideMatch = [1 2];


%add zaber
 s. zaber.  use = 1;

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
% 
% %%% Debugging settings
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