function s = plaid_TestSettings

s.display.viewdist = 50; %viewing distance in cm (about halfway point)

s.stimulus.radius=10; %stimulus radius in deg
%s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.6*s.stimulus.radius; %switch from open mask to exponential function
s.stimulus.sf=0.25; %spatial frequency
s.stimulus.t_period=15; %frames for 1 cycle
s.stimulus.phase=0; %phase
s.stimulus.iAngle=90; %intersection angle between gratings
s.stimulus.offset=[600 -600 0];

s.ports.nPorts = 4;

%turn adc channels off
s.datapixx.useAsPorts = 0;
s.datapixx.adc.channels = [];

%turn mouse input on
s.mouse.useAsPort = 1;
s.mouse.use = 1;

%turn saving off
s.pldaps.nosave = 1;

