function s = ori_passive_viewSettings
% turn saving off
s.pldaps.nosave = 1;

%set reward amounts
s. behavior.   reward. amount = [0.04 0.08 0.08];
s.behavior.reward.amountDelta = 0.01;

%set orientation and offsets
s.stimulus.offsets = {[0:22.5:90]};
s.stimulus.angle = 0;
s.stimulus.sf = 0.08;
s.stimulus.range = 121;
s.stimulus.baseline = 0.3;
s.stimulus.stimON = 0.6;
s.stimulus.waitTime = 0.3;
s.stimulus.runtype = 'pseudo';
s.stimulus.lickdelay = 2;
s.stimulus.duration.ITI = 1.5;
%set up the viewing distance
s.display.viewdist = 30; 
% 
s.stimulus.fullField = zeros(1,length(s.stimulus.offsets));


s.stimulus.radius=30; %stimulus radius in deg
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.6*s.stimulus.radius; %switch from open mask to exponential function


% %configure ports
 s.ports.use = true;
 s.ports.nports = 3;
 s.ports.movable = true;
 s.datapixx.adc.channels = [1 3 5];
%  
%  %turn mouse input off
% s.mouse.useAsPort = 0;
% s.mouse.use = 0;

% %%% Debugging settings
% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
% 
