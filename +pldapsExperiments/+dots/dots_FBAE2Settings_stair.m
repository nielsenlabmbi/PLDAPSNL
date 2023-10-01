function s = dots_FBAD8Settings_stair
% % turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
%s. behavior.   reward. amount = [0.1 0.35 0.375 0.35];
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
%set orientation and offsets
s.stimulus.dotSize = 1.5;
s.stimulus.nrDots = 100;
%set background color, wait color, and dot color 
s.display.bgColor = [0 0 0]; % 
s.stimulus.fractionBlack = 0;
s.stimulus.dotCoherence = 1; 
s.stimulus.dotSpeed = 0.4;%sxs
s.stimulus.dotLifetime = 3;%s
s.stimulus.durStim = 60;
s.stimulus.frameRate = 120;
s.stimulus.direction = [0 180];
s.stimulus.stair= 1;
s.stimulus.step=0.05;

%set viewing parameters
s.stimulus.baseline = 0.2;
s.stimulus.lickdelay = 1.0;
s.stimulus.duration.ITI = 1.5;
s.stimulus.stimON = 0.2;
s.stimulus.waitTime = 0; 



%set up the viewing distance
s.display.viewdist = 75; 
% %add camera
%s.camera.use=1;


% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
