
function s = dots_FBAD7Settings_stair
% % turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
%s. behavior.   reward. amount = [0.1 0.35 0.375 0.35];
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
%set orientation and offsets
s.stimulus.dotSize = 1.5;
s.stimulus.nrDots = 100;
%set background color, wait color, and dot color *RV cannot change colors
s.display.bgColor = [.5 .5 .5]; % 000 is black , .5.5.5 debes grey but still looks black to me.
% 1 1 1 also reamains black
%s.stimulus.dotColor = 0; %added this s.s to see if it works, it does not
s.stimulus.fractionBlack = 1; % 0 is all white, 
s.stimulus.dotCoherence = 1; 
s.stimulus.dotSpeed = 0.6;%sxs
s.stimulus.dotLifetime = 3;%s
s.stimulus.durStim = 60;
s.stimulus.frameRate = 120;
s.stimulus.direction = [0 180];
s.stimulus.stair=[0 1];
s.stimulus.step=0.05;

%set viewing parameters
s.stimulus.baseline = 0.2;
s.stimulus.lickdelay = 1.3;
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
