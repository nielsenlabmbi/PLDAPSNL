function s = lesion_X0000Settings_P6
%This is the test phase across coherences


% % turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];

%set stimulus parameters
s.stimulus.dotSize = 0.7;
s.stimulus.dotDensity = 0.75; %dots/deg^2
s.stimulus.dotColor = 0;

%need to change these one by one if using 'easier' coherence
%6/6/25, still needs adjustment to code in lesion_dots_setup_free_P6
%s.stimulus.dotCoherence =  1; %regulated by staircase, this is start value
s.stimulus.dotCoherence =  {[1, 0.8, 0.6, 0.4, 0.2]};
%s.stimulus.dotCoherence =  {[1, 0.8]};
%s.stimulus.dotCoherence =  {[1, 0.8, 0.6]};
%s.stimulus.dotCoherence =  {[1, 0.8, 0.6, 0.4]};

s.stimulus.dotSpeed = 48; %deg/sec
s.stimulus.dotLifetime = 25; %ms, 
s.stimulus.direction = [0 180];
s.stimulus.width=10; %deg
%s.stimulus.height=; %deg
s.stimulus.centerX=990; %pixels
s.stimulus.centerY=540;

s.stimulus.offset=15; %start offset in deg
s.stimulus.delta_offset = 5;%in deg

%offset is converted to pixel space from dimensions off rig/monitor
%36.6 = PPcm
%25cm from tunnel wall mouth to screen
s.stimulus.stimSide= [-1 1];

s.display.bgColor = [.5 .5 .5]; 

%staircase parameters
s.stimulus.stair=0; %[0 1] if on space bar;
s.stimulus.step=0.05;

%viewing parameters

s.display.viewdist = 75; %cm

s.stimulus.durStim = 5; %sec
s.stimulus.delta_durStim = 1; %sec

%settings at lower scale
%s.stimulus.durStim = .6
%s.stimulus.delta_durStim = 0.1 


s.stimulus.frameRate = 120;
s.stimulus.duration.ITI = 0.2;
s.stimulus.midpointIR = 1; %turn stimulus on when crossing midline

%2/23/25 - Issue w/ IR ports after IR slot expansion; adding these lines
%s.datapixx.adc.channels = [2 4 6];
%s.ports.nports=3;

% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
