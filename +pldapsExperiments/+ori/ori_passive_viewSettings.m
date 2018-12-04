function s = ori_passive_viewSettings


%set reward amounts
s. behavior.   reward. amount = [0.04 0.08 0.08];
s.behavior.reward.amountDelta = 0.01;

%set orientation and offsets
s.stimulus.offsets = {[0:22.5:90]};
s.stimulus.angle = 0;
s.stimulus.sf = 0.08;
s.stimulus.range = 121;
s.stimulus.baseline = 0.3;
s.stimulus.stimON = 1;
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
 
% %turn saving off
s.pldaps.nosave = 1;
 
% %two-p settings
%  s.datapixx.dio.useForReward = 1; 
%  s.datapixx.adc.useForReward = 0;
%  s. behavior.   reward. channel. START = 7; %dio channel for reward delivery
%  s. behavior.   reward. channel. LEFT = 6;
%  s. behavior.   reward. channel. RIGHT = 5;
%  s.datapixx.din.channels.ports = [18 20 22];
%  s. pldaps. nosave = 0;

% %%% Debugging settings
% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
