function s = drifting_passive_viewSettings_ephys


%set reward amounts
s. behavior.   reward. amount = [0.04 0.08 0.08];
s.behavior.reward.amountDelta = 0.01;

%set orientation and offsets
s.stimulus.direction = {[0:30:360]};
s.stimulus.t_period = 20;
s.stimulus.offsets = {[0:22.5:90]};
s.stimulus.angle = 0;
s.stimulus.sf = 0.08;
s.stimulus.range = 121;
s.stimulus.baseline = 0.5;
s.stimulus.reference_baseline = 1; %0.5;
s.stimulus.stimON = 1;
s.stimulus.stimdur = 1;
s.stimulus.waitTime = 1;
s.stimulus.runtype = 'pseudo';
s.stimulus.lickdelay = 1.5;
s.stimulus.duration.ITI = 2;
%set up the viewing distance
s.display.viewdist = 30; 
% 
s.stimulus.fullField = zeros(1,length(s.stimulus.offsets));


s.stimulus.radius=30; %stimulus radius in deg
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.6*s.stimulus.radius; %switch from open mask to exponential function


% %configure ports
 s.ports.use = true;
 s.ports.nPorts = 3;
 s.ports.movable = true;
 s.datapixx.adc.channels = [1 3 5];
 
 s.datapixx.din.useFor.ports = 1;

s.ephys.use = 1;

% s.session.subject = 'fbab6';
% s.session.unit = '000';
% s.session.expt = '000';

%%% Debugging settings

%turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;

% % turn saving off
% s.pldaps.nosave = 1;
