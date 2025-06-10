function s = lesion_dots_settings_P3_XXXX0
%This phase adjusts the dot density and dot size 

%%%these parameters can get changed
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
s.stimulus.dotSize = 1.5; %start size (deg)
s.stimulus.delta_size = .1; %step size for size (up/down key)
s.stimulus.dotDensity = 0.12; %start density (dots/deg^2)
s.stimulus.delta_den = .15; %step size for density (left/right key)
s.display.viewdist = 75; %cm
s.stimulus.duration.ITI = 0.2;

%%%these parameters should not be changed without discussion
s.stimulus.dotColor = 0;
s.stimulus.dotCoherence =  1; 
s.stimulus.dotSpeed = 48; %deg/sec
s.stimulus.dotLifetime = 25; %ms, 
s.stimulus.direction = [0 180];
s.stimulus.frameRate = 120;
s.display.bgColor = [.5 .5 .5]; 
s.stimulus.durStim = 30; %sec
s.stimulus.midpointIR = 1; %turn stimulus on when crossing midline


%s.datapixx.adc.channels = [2 4 6];
%s.ports.nports=3;
