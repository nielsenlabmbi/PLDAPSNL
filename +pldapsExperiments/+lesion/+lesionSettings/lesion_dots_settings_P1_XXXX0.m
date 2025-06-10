function s = lesion_dots_settings_P1_XXXX0
%this phase implements basic left/right dot discrimination

%%%these parameters can get changed
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
s.display.viewdist = 75; %cm
s.stimulus.duration.ITI = 0.2;


%%%these parameters should not be changed without discussion
s.stimulus.dotSize=1.5; %deg
s.stimulus.dotDensity = 0.12; %dots/deg^2
s.stimulus.dotColor = 0;
s.stimulus.dotCoherence =  1; 
s.stimulus.dotSpeed = 48; %deg/sec
s.stimulus.dotLifetime = 25; %ms, 
s.stimulus.direction = [0 180];
s.stimulus.frameRate = 120;
s.display.bgColor = [.5 .5 .5]; 
s.stimulus.durStim = 30; %sec

%s.datapixx.adc.channels = [2 4 6];
%s.ports.nports=3;

