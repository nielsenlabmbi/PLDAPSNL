function s = ori_FBAC3Settings
% turn saving off
% s.pldaps.nosave = 1;
%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
%set orientation and offsets
s.stimulus.sf = [0.25]; % cycles per degree, may be a vector
s.stimulus.angle = [0 90]; % side matched
s.stimulus.range = [121]; %contrast, range between 1 and 127, may be a vector
s.stimulus.runtype = 'pseudo';
s.stimulus.fullField = 0;
s.stimulus.midpointIR = 1; %use midpoint IR beam to turn off stimulus


%set viewing parameters
s.stimulus.radius=12; %stimulus radius in deg
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.6*s.stimulus.radius; %switch from open mask to exponential function
s.stimulus.duration.ITI = 2;
%set up the viewing distance
s.display.viewdist = 75; 

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