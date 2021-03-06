function s = drifting_passive_viewSettings_ephys


%set reward amounts
s. behavior.   reward. amount = [0.04 0.08 0.08];
s.behavior.reward.amountDelta = 0.01;

%set orientation and offsets
s.stimulus.direction = {[0:22.5:360]};
s.stimulus.t_period = 20;
s.stimulus.offsets = {[0:22.5:90]};
s.stimulus.angle = 0;
s.stimulus.sf = 0.125;
s.stimulus.range = 121;
s.stimulus.baseline = 0.5;
s.stimulus.reference_baseline = 0.5;
s.stimulus.stimON = 1;
s.stimulus.stimdur = 1;
s.stimulus.waitTime = 1;
s.stimulus.runtype = 'pseudo';
s.stimulus.lickdelay = 1.5;
s.stimulus.duration.ITI = 1;
%set up the viewing distance
s.display.viewdist = 45; 
% 
s.stimulus.fullField = zeros(1,length(s.stimulus.offsets));


s.stimulus.radius=20; %stimulus radius in deg
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.8*s.stimulus.radius; %switch from open mask to exponential function


% %configure ports
 s.ports.use = true;
 s.ports.nPorts = 3;
 s.ports.movable = true;
 s.datapixx.adc.channels = [1 3 5];
 
 s.datapixx.din.useFor.ports = 1;

%s.ephys.use = 1;

%%% Debugging settings

%turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;

% % turn saving off
% s.pldaps.nosave = 1;
