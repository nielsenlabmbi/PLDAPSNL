function s = orithres_FBAC6Settings

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
%set orientation and offsets
s.stimulus.midpointIR = 0; %use midpoint IR beam to turn off stimulus
s.stimulus.angle = horzcat({[90]},{[90 45 30 15]});
s.stimulus.sf = 0.25;
s.stimulus.range = 121;
s.stimulus.runtype = 'pseudo';
s.stimulus.fullField = 0;
s.stimulus.sidePar = [0 1];

%set viewing parameters
s.stimulus.radius=12; %stimulus radius in deg
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.6*s.stimulus.radius; %switch from open mask to exponential function
s.stimulus.duration.ITI = 2;
%set up the viewing distance
s.display.viewdist = 75; 
% 
%
% % Debugging settings
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