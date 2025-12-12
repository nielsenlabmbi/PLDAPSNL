function s = lesion_dots_settings_P7Level_FBAE6
%measure psychometric functions for both sides using staircase
%left arrpw turns left staircase on/off
%right arrow turns right staircase on/off

%%%these parameters can get changed
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
s.stimulus.durStim = 10; %ferret specific stimulus duration (sec)
s.stimulus.stairL=0; %staircase state L (off initially)
s.stimulus.dotCoherenceL =  1; %start level L
s.stimulus.delta_cohL =  0.1; %coherence staircase step L
s.stimulus.stairR=0; %staircase state R 
s.stimulus.dotCoherenceR =  1; %start level R
s.stimulus.delta_cohR =  0.1; %coherence staircase step R
s.display.viewdist = 57; %cm
s.stimulus.duration.ITI = 0.2;


%%%these parameters should not be changed without discussion
s.stimulus.dotSize=0.7; %deg
s.stimulus.dotDensity = 0.75; %dots/deg^2
s.stimulus.dotColor = 0;
s.stimulus.dotSpeed = 48; %deg/sec
s.stimulus.dotLifetime = 25; %ms, 
s.stimulus.direction = [0 180];
s.stimulus.frameRate = 120;
s.display.bgColor = [.5 .5 .5]; 
s.stimulus.width=10; %deg
s.stimulus.stimSide= [-1 1];
s.stimulus.midpointIR = 1; %turn stimulus on when crossing midline
s.stimulus.centerY=540; %vertical stimulus position (pixels)
s.stimulus.offset=15; %horizontal offset in deg (from point where stimulus turns on)
s.datapixx.adc.channels = [2 4 6 8 10];
s.ports.nPorts=5;
s.ports.adc.portThreshold = [2 2 2 -2 2]';
s.ports.adc.portPol = [1 1 1 -1 1]';
s.ports.adc.portAvg = 1;

s.stimulus.dotCoherence = [1:-0.2:0.2];

s.stimulus.iniMatchType=0; %value:  0-normal, 1-non-matching choice, 2-matching choice
s.stimulus.cond.Ncond=[4,20]; %either 2 sides x 2 dir, or 2 sides x 2 dir x 5 coh 
%mapping: separate for sides and coherence, but not dir
s.stimulus.cond.counterIdx{1}=[1 3 2 4]; %index into the counter for each condition
s.stimulus.cond.counterIdx{2}=[1:10 1:10]; %index into the counter for each condition
s.stimulus.cond.counterNames{1}={'L-0';'R-0';'L-180';'R-180'};
s.stimulus.cond.counterNames{2}={'L-100';'L-80';'L-60';'L-40';'L-20';...
    'R-100';'R-80';'R-60';'R-40';'R-20'};

