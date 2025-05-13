function s = ori_FBAE5Settings

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
%set orientation and offsets
s.stimulus.midpointIR = 0; %use midpoint IR beam to turn off stimulus
%s.stimulus.offsets = horzcat({[25]},{[25]});
%s.stimulus.offsets = horzcat({[22]},{[22]},{[25 15 10 8 5]});
%s.stimulus.offsets = horzcat({[22]},{[22]},{[6]});
s.stimulus.shift = [0 0];
s.stimulus.angle = [0 90];

s.stimulus.offStim=1;



s.stimulus.sf = 0.1;
s.stimulus.range = 121;
s.stimulus.runtype = 'pseudo';
s.stimulus.fullField = [1 0];
%s.stimulus.sideMatch = [1 -1];


%set viewing parameters
s.stimulus.radius=12; %stimulus radius in deg
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.6*s.stimulus.radius; %switch from open mask to exponential function
s.stimulus.duration.ITI = 2;
%set up the viewing distance
s.display.viewdist = 75; 

%2/23/25 - Issue w/ IR ports after IR slot expansion; adding these lines
s.datapixx.adc.channels = [2 4 6];
s.ports.nports=3;

s.camera.use = 1;
s.camera.trigger.channel = 1;
%s.datapixx.dout.cameraTriggerLine = 0;  % DOUT0 for camera TTL
%s.camera.triggerDuration = 0.001;       % 1ms pulse width

%s.datapixx.adc.channels = [1 3 5];

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

