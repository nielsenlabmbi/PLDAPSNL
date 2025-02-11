function s = dots_FBAD3Settings_patch

%FEMALE
%664901 = ANIMAL ID

% % turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];

%set stimulus parameters
s.stimulus.dotSize = 1.5;
s.stimulus.dotDensity = 0.12; %dots/deg^2
s.stimulus.dotColor = 0;
s.stimulus.dotCoherence =  1; %regulated by staircase, this is start value
s.stimulus.dotSpeed = 48; %deg/sec
s.stimulus.dotLifetime = 25; %ms, 
s.stimulus.direction = [0 180];
s.stimulus.width=40; %deg
s.stimulus.height=20; %deg
s.stimulus.centerX=990; %pixels
s.stimulus.centerY=540;

s.display.bgColor = [.5 .5 .5]; 

%staircase parameters
s.stimulus.stair=1; %[0 1] if on spacebar
s.stimulus.step=0.05;

%viewing parameters
s.display.viewdist = 60; 
s.stimulus.durStim = [60 2 1 0.5 0.4 0.3 0.25]; %sec
s.stimulus.frameRate = 120;
s.stimulus.duration.ITI = 0.2; %intertrial interval
s.stimulus.midpointIR = 1; %turn stimulus on when crossing midline



% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
