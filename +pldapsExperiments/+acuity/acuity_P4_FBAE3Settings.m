function s = acuity_P4_FBAE3Settings

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];

%set orientation and offsets
s.stimulus.midpointIR = 1; %use midpoint IR beam to turn off stimulus
s.stimulus.angle = [0 90];


s.stimulus.sf = 0.1;
s.stimulus.range = {127;[127 100 50 20 6]; [127 50 25 15 10 6]};
s.stimulus.runtype = 'pseudo';
s.stimulus.fullField = 0;


%set viewing parameters
s.stimulus.radius=12; %stimulus radius in deg
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.6*s.stimulus.radius; %switch from open mask to exponential function
s.stimulus.duration.ITI = 2;

%set up the viewing distance
s.display.viewdist = 46; 

%camera
s.camera.use = 0;
s.camera.trigger.channel = 6;



% 
% % Debugging settings
% 
%turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
%turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
% 
% % turn saving off
% s.pldaps.nosave = 1;

