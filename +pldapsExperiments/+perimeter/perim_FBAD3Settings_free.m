function s = perim_FBAD3Settings_free

%FEMALE
% = ANIMAL ID

% % turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];

%set stimulus parameters
s.stimulus.dotSize = 2.0;% deg; original 1.5
s.stimulus.windowWidth=300; %pixels
s.stimulus.windowHeight= 300; %pixels
s.stimulus.centerY=810;%pixels
s.stimulus.centerX=1000; %pixels, original 960
s.stimulus.offset= 480; %in pixels, relative to center, should be larger than windowWidth/2
s.stimulus.stimSide= [-1 1]; % set to [-1 1] to alternate sides
s.stimulus.randPos=[0 1]; %0 is off - fixed position at x=centerScreen+offset, y=centerY; [0 1] puts it on the spacebar
s.stimulus.posSpacing = 50; %spacing between sampled positions in pixels
s.stimulus.flashDot=1; %0 is off
s.stimulus.flashRate=6; %frames
s.stimulus.dotColor = 0; %default color, 0 = black
s.stimulus.flashColor = 1; %alternate color when flashing
s.display.bgColor = [.5 .5 .5]; 


%viewing parameters
s.display.viewdist = 60; %cm
s.stimulus.startStim = 0.10; %start at .35, down to .20 RV 20230920
s.stimulus.durStim = 10.0; %sec - for intitial training time to see and dot in atrium
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
