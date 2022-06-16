function s = drifting_FBAB3Settings

%set reward amounts
s. behavior.   reward. amount = [0.02 0.08 0.08];
s.behavior.reward.pulseFreq = 3;
s.behavior.reward.pulseInt = 0.2;
s.behavior.reward.amountDelta = 0.01;

%set viewing parameters
s.stimulus.baseline = 0.1;
s.stimulus.lickdelay = 1.5;
s.stimulus.forceCorrect_delay = 0.75;
s.stimulus.duration.ITI = 1;
s.stimulus.stimON = 0.3;
s.stimulus.waitTime = 0.8;
s.stimulus.trialdur = 120;
s.stimulus.timeout = 2; 
s.stimulus.shift = [400 -400];

%set instructive trials
s.stimulus.fracInstruct =1;

%dots parameters
s.stimulus.dotSize = 1.5;
s.stimulus.nrDots = 250;
s.stimulus.fractionBlack = 0.5;
s.stimulus.dotCoherence = 1;
s.stimulus.dotSpeed = 0.4;
s.stimulus.dotLifetime = 240;
s.stimulus.durStim = 480;
s.stimulus.frameRate = 120;

%gratings parameters
s.display.viewdist = 45; %viewing distance in cm
s.stimulus.radius=20; %stimulus radius in deg
s.stimulus.sigma=2*s.stimulus.radius/16.5;
s.stimulus.maskLimit=.6*s.stimulus.radius; %switch from open mask to exponential function
s.stimulus.sf=0.125; %spatial frequency
s.stimulus.t_period=[20]; %frames for 1 cycle
s.stimulus.phase=0; %phase


%run/condition specific parameters
s.stimulus.runtype='pseudo'; %or block
s.stimulus.blocklength=2; %only used in blocks
s.stimulus.stimtype = [2];

% %configure ports
 s.ports.use = true;
 s.ports.nports = 3;
 s.ports.movable = true;
 s.datapixx.adc.channels = [1 3 5]; %[1 3 5 10 11];
 s.datapixx.useAsEyepos = 0;
 s.datapixx.din.useFor.ports = 1;
 %turn mouse input off
s.mouse.useAsPort = 0;
s.mouse.use = 0;

% Debugging
%turn adc channels off
s.datapixx.useAsPorts = 0;
s.datapixx.adc.channels = [];

%turn mouse input on
s.mouse.useAsPort = 1;
s.mouse.use = 1;

%turn saving off
s.pldaps.nosave = 1;

