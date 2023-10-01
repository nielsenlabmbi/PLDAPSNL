function s = dots_FBAD3Settings_patchOff

%FEMALE
%664901 = ANIMAL ID

% % turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];

%set stimulus parameters
s.stimulus.dotSize = 1.25; %Originally set to 1.5
s.stimulus.dotDensity = 0.13; %dots/deg^2, originally set to 0.12
s.stimulus.dotColor = 0;
s.stimulus.dotCoherence =  1.0; %regulated by staircase, this is start value
s.stimulus.dotSpeed = 48; %deg/sec
s.stimulus.dotLifetime = 25; %ms, 
s.stimulus.direction = [0 180];
s.stimulus.patchWidth= 15; %deg ORIGINAL 12
s.stimulus.patchHeight= 25; %deg
s.stimulus.centerX=990; %pixels
s.stimulus.centerY=810;
s.stimulus.offset=[100 200 300 400 500 600]; %First setting is 0, increase to 3 with spacebar
s.stimulus.stimSide= [-1 1]; % [-1 1] to alternate, controls which side of screen stim ocures on, modified 5/17 to be locked on one side

s.display.bgColor = [.5 .5 .5]; 

%staircase parameters
s.stimulus.stair=0; %[0 1] if on space bar, 0 off, 1 on;
s.stimulus.step=0.05;

%viewing parameters

s.display.viewdist = 60; %cm
s.stimulus.startStim = 0.35;
s.stimulus.durStim = 0.3; %sec - can be further regulated with user keys
s.stimulus.frameRate = 120;
s.stimulus.duration.ITI = 0.2;
s.stimulus.midpointIR = 1; %turn stimulus on when crossing midline



% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
