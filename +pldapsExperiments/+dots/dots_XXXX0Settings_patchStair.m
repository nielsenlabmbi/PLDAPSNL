function s = dots_XXXX0Settings_patchStair

%FEMALE
%664901 = ANIMAL ID

% % turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];

%set stimulus parameters
s.stimulus.dotSize = 0.7;% original 1.5
s.stimulus.dotDensity = 0.75; %dots/deg^2
s.stimulus.dotColor = 0;
s.stimulus.dotCoherence =  1; %regulated by staircase, this is start value
s.stimulus.dotSpeed = 24; %deg/sec
s.stimulus.dotLifetime = 25; %ms, 
s.stimulus.direction = [0 180];
s.stimulus.patchWidth=10; %deg ORGINAL 12
s.stimulus.patchHeight= 10; %deg
s.stimulus.centerX=990; %pixels
s.stimulus.centerY=810;
s.stimulus.offset= [600 600]; %can now accept different offsets for left and right
s.stimulus.stimSide= [-1 1]; % set to [-1 1] to alternate sides

s.display.bgColor = [.5 .5 .5]; 

%staircase parameters
s.stimulus.stair= [0 1]; %[0 1] if on space bar;
s.stimulus.step=0.05;

%viewing parameters

s.display.viewdist = 50; %cm
s.stimulus.startStim = 0;
s.stimulus.durStim = 5; %sec - shorten from .3 to .15 on 9/18/23
s.stimulus.frameRate = 120;
s.stimulus.duration.ITI = 0.2;
s.stimulus.midpointIR = 0; %turn stimulus on when crossing midline



% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
