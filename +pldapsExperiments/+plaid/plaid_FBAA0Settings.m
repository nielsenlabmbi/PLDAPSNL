function s = plaid_FBAA0Settings

%general stimulus parameters
s.display.viewdist = 50; %viewing distance in cm (about halfway point)
s.stimulus.radius=10; %stimulus radius in deg
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.6*s.stimulus.radius; %switch from open mask to exponential function
s.stimulus.sf=0.25; %spatial frequency
s.stimulus.t_period=15; %frames for 1 cycle
s.stimulus.phase=0; %phase
s.stimulus.iAngle=90; %intersection angle between gratings
s.stimulus.iniOffset=[200 -200 0];
s.stimulus.deltaOffset=[-50 50 0];
s.ports.nPorts = 4;

%dots parameters
%set orientation and offsets
s.stimulus.dotSize = 1.436*1.5;
s.stimulus.nrDots = 100;
s.stimulus.fractionBlack = 0.5;
s.stimulus.dotCoherence = 1;
s.stimulus.dotSpeed = 1.436*0.6;
s.stimulus.dotLifetime = 240;
s.stimulus.durStim = 60;
s.stimulus.frameRate = 120;


%run/condition specific parameters
s.stimulus.runtype='pseudo'; %or block
s.stimulus.blocklength=2; %only used in blocks
s.stimulus.ori1=[45 90 135];
s.stimulus.ori = [45 90 135];
s.stimulus.plaid=0;
s.stimulus.plaid1 = 0;
s.stimulus.stimtype = 1; %[1 1 2];
s.stimulus.stimtype1 = 2; %[1 2];

s.behavior.reward.amount = [0.1 0.25 0.25 0.25];







