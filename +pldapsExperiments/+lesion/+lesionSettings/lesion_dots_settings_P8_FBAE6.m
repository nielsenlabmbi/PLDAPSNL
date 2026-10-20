function s = lesion_dots_settings_P8_FBAE6
%measure psychometric functions for both sides using staircase
%left/right arrow changes offset
%up/down changes coherence

%%%these parameters can get changed
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
s.stimulus.durStim = 10; %ferret specific stimulus duration (sec)
s.display.viewdist = 57; %cm
s.stimulus.duration.ITI = 0.2;
s.stimulus.delta_offset = 1;%step size for offset in deg
s.stimulus.delta_coh = 0.1;%step size for offset in deg
s.stimulus.dotCoherence = .5;
s.stimulus.offset=5; %horizontal offset in deg (from point where stimulus turns on)

%%%these parameters should not be changed without discussion
s.stimulus.dotSize=0.7; %deg
s.stimulus.dotDensity = 0.75; %dots/deg^2
s.stimulus.dotColor = 0;
s.stimulus.dotSpeed = 48; %deg/sec
s.stimulus.dotLifetime = 25; %ms, 
s.stimulus.direction = [0 180];
s.stimulus.frameRate = 120;
s.display.bgColor = [.5 .5 .5]; 
s.stimulus.width=5; %deg
s.stimulus.stimSide= [-1 1];
s.stimulus.midpointIR = 1; %turn stimulus on when crossing midline
s.stimulus.centerY=540+360; %vertical stimulus position (pixels)
%adjust center Y to [540-360; 540; 540+360];
%                   [top stim; middle stim; bottom stim];
%                      top = 0 bottom = 1080
s.datapixx.adc.channels = [2 4 6 8 10];
s.ports.nPorts=5;
s.ports.adc.portThreshold = [2 2 2 -2 2]';
s.ports.adc.portPol = [1 1 1 -1 1]';
s.ports.adc.portAvg = 1;



s.stimulus.iniMatchType=0; %value:  0-normal, 1-non-matching choice, 2-matching choice
s.stimulus.cond.Ncond=4; %either 2 sides x 2 dir, or 2 sides x 2 dir x 5 coh 
%mapping: separate for sides and coherence, but not dir
s.stimulus.cond.counterIdx{1}=[1 3 2 4]; %index into the counter for each condition
s.stimulus.cond.counterNames{1}={'L-0';'R-0';'L-180';'R-180'};

