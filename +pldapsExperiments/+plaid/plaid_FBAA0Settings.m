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
s.stimulus.offset=[600 -600 0];
s.ports.nPorts = 4;

%run/condition specific parameters
s.stimulus.runtype='pseudo'; %or block
s.stimulus.blocklength=2; %only used in blocks
s.stimulus.ori=[45 90 135];
s.stimulus.plaid=0;

s.behavior.reward.amount = [0.15 0.4 0.3 0.5];







