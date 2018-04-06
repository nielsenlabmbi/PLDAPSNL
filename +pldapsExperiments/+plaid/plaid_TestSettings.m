function s = plaid_TestSettings

%general stimulus parameters
s.display.viewdist = 75; %viewing distance in cm (about halfway point)
s.stimulus.radius=10; %stimulus radius in deg
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.6*s.stimulus.radius; %switch from open mask to exponential function
s.stimulus.sf=0.25; %spatial frequency
s.stimulus.t_period=50; %frames for 1 cycle
s.stimulus.phase=0; %phase
s.stimulus.iAngle=90; %intersection angle between gratings
s.stimulus.iniOffset=[0 0 0];
s.stimulus.deltaOffset=[-50 50 0];
s.ports.nPorts = 4;

%run/condition specific parameters
s.stimulus.runtype='pseudo'; %or block
s.stimulus.blocklength=2; %only used in blocks
s.stimulus.ori=[0 90];
s.stimulus.plaid=[0];
s.stimulus.plaid1 = [0 1 1 1 1];

%turn adc channels off
s.datapixx.useAsPorts = 0;
s.datapixx.adc.channels = [];

%turn mouse input on
s.mouse.useAsPort = 1;
s.mouse.use = 1;

%turn saving off
s.pldaps.nosave = 1;

