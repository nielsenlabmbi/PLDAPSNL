function s = dots_FBAD7Settings_patchSize

%FEMALE w/headpost
%669821 = ANIMAL ID

% % turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];

%set stimulus parameters
s.stimulus.dotSize = 1.25;% original 1.5
s.stimulus.dotDensity = 0.13; %dots/deg^2
s.stimulus.dotColor = 0;
s.stimulus.dotCoherence =  1.0 ; %can be regulated by staircase, this is start value
s.stimulus.dotSpeed = 48; %deg/sec
s.stimulus.dotLifetime = 100000; %ms, 
s.stimulus.direction = [0 180];
s.stimulus.patchWidth=[30 25 20 15]; %deg ORGINAL 12, 50 is full
s.stimulus.patchHeight= 30; %deg

s.stimulus.centerX= 990; %pixels
s.stimulus.centerY= 810; %500 puts in center, 810 is bottom
s.stimulus.offset= 0;% first is setting 0, increase with spacebar
s.stimulus.stimSide= -1; % set to [-1 1] to alternate sides

s.display.bgColor = [.5 .5 .5]; 

%staircase parameters
s.stimulus.stair=0; %[0 1] if on space bar;
s.stimulus.step=0.05;

%viewing parameters

s.display.viewdist = 60; %cm
s.stimulus.startStim = 0.35;
s.stimulus.durStim = 2.0; %seconds  dots play
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
