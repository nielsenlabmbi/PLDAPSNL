function s = dots_FBAD5Settings_patchStair

%FEMALE
%664901 = ANIMAL ID

% % turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];

%set stimulus parameters
s.stimulus.dotSize = 1.25;% original 1.5
s.stimulus.dotDensity = 0.13; %dots/deg^2
s.stimulus.dotColor = 0;
s.stimulus.dotCoherence =  1.0; %regulated by staircase, this is start value
s.stimulus.dotSpeed = 48; %deg/sec
s.stimulus.dotLifetime = 25; %ms, 
s.stimulus.direction = [0 180];
s.stimulus.patchWidth=15; %deg ORGINAL 12
s.stimulus.patchHeight= 20; %deg
s.stimulus.centerX=990; %pixels
s.stimulus.centerY=810;
s.stimulus.offset= 500;
s.stimulus.stimSide= [-1 1]; % set to [-1 1] to alternate sides

s.display.bgColor = [.5 .5 .5]; 

%staircase parameters
s.stimulus.stair= [0 1]; %[0 1] if on space bar;
s.stimulus.step=0.05;

%viewing parameters

s.display.viewdist = 60; %cm
s.stimulus.startStim = 0.15;
s.stimulus.durStim = 0.15; %sec - shorten from .3 to .15 on 9/18/23
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
