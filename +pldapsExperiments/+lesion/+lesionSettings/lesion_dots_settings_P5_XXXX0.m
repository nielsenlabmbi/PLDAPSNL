function s = lesion_dots_settings_P5_XXXX0
%This phase adjusts the stimulus offset

%%%these parameters can get changed
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
s.stimulus.offset=5; %start offset in deg (from point where stimulus turns on)
s.stimulus.delta_offset = 2.5;%step size for offset in deg
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
s.stimulus.durStim = 30; %sec
s.stimulus.width=10; %deg
s.stimulus.stimSide= [-1 1];
s.stimulus.midpointIR = 1; %turn stimulus on when crossing midline
s.stimulus.centerY=540; %vertical stimulus position (pixels)
s.stimulus.matchType=0; %values between 0-normal, 1-non-matching choice, 2-matching choice

