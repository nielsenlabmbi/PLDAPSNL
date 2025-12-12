function s = acuity_P4_FBAE3Settings_tunnel


%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];

%set orientation and offsets
s.stimulus.midpointIR = 1; %use midpoint IR beam to turn off stimulus
s.stimulus.angle = [0 90];


%s.stimulus.sf = 0.3; %began 9/15/25 - 9/24
s.stimulus.sf = 0.2; %began 11/25/25 - doing this for glasses testing
s.stimulus.range = {127;[127 100]; [127 100 50 20 6]; [127 50 25 15 10 6]};
s.stimulus.runtype = 'pseudo';
s.stimulus.fullField = 0;
s.stimulus.removeStim = 0; %toggle whether stimulus will remain following exit tunnel
% 0 = leave stimulus on (left key)
% 1 = remove stimulus (right key)

%set viewing parameters
s.stimulus.radius=12; %stimulus radius in deg
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.6*s.stimulus.radius; %switch from open mask to exponential function
s.stimulus.duration.ITI = 1;

%set up the viewing distance
s.display.viewdist = 46; 

%camera
s.camera.use = 0;
s.camera.trigger.channel = 6;

s.datapixx.adc.channels = [2 4 6 8 10];
s.ports.nPorts=5;
s.ports.adc.portThreshold = [2 2 2 -2 2]';
s.ports.adc.portPol = [1 1 1 -1 1]';
s.ports.adc.portAvg = 1;

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

