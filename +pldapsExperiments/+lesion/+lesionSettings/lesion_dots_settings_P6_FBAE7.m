function s = lesion_dots_settings_P6_FBAE7
%This phase adjusts the stimulus duration

%%%these parameters can get changed
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
s.stimulus.durStim = 2; %start stimulus duration (sec)
s.stimulus.delta_durStim = 0.1; %step size stimulus duration (sec)
s.display.viewdist = 38; %cm
s.stimulus.duration.ITI = 0.2;


%%%these parameters should not be changed without discussion
s.stimulus.dotSize=0.7; %deg
s.stimulus.dotDensity = 0.75; %dots/deg^2
s.stimulus.dotColor = 0;
s.stimulus.dotCoherence =  1; 
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
s.ports.adc.portThreshold = [2 2 2 2 0.1]';
s.ports.adc.portPol = [1 1 1 1 -1]';


