function s = plaid_FBAA4Settings

%general stimulus parameters
s.display.viewdist = 75; %viewing distance in cm (about halfway point)
s.stimulus.radius=10; %stimulus radius in deg
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.6*s.stimulus.radius; %switch from open mask to exponential function
s.stimulus.sf=0.25; %spatial frequency
s.stimulus.t_period=15; %frames for 1 cycle
s.stimulus.phase=0; %phase
s.stimulus.iAngle=90; %intersection angle between gratings
s.stimulus.iniOffset=[0 0 0];
s.stimulus.deltaOffset=[-50 50 0];
s.ports.nPorts = 4;

%dots parameters
%set orientation and offsets
s.stimulus.dotSize = 1.5;
s.stimulus.nrDots = 100;
s.stimulus.fractionBlack = 0.5;
s.stimulus.dotCoherence = 1;
s.stimulus.dotSpeed = 0.6;
s.stimulus.dotLifetime = 240;
s.stimulus.durStim = 60;
s.stimulus.frameRate = 120;


%run/condition specific parameters
s.stimulus.runtype='pseudo'; %or block
s.stimulus.blocklength=2; %only used in blocks
s.stimulus.ori=[45 90 135];
s.stimulus.ori1 = 90;
s.stimulus.plaid=0;
s.stimulus.plaid1 = 1;
s.stimulus.stimtype1 = 1;
s.stimulus.stimtype = [1 2]; %[1 1 1 2];

s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
% % 
% 
% 
% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
% 
% %turn saving off
% s.pldaps.nosave = 1;



