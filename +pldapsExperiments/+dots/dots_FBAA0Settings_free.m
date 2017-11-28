function s = dots_FBAA0Settings_free
% % turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
s. behavior.   reward. amount = [0.075 0.25 0.25 0.25];

%set orientation and offsets
s.stimulus.dotSize = 1.5;
s.stimulus.nrDots = 100;
s.stimulus.fractionBlack = 0.5;
s.stimulus.dotCoherence = [0.2 0.4 0.6 0.8 1];
s.stimulus.dotSpeed = 0.4;
s.stimulus.dotLifetime = [3 240];
s.stimulus.durStim = 60;
s.stimulus.frameRate = 120;

%set up the viewing distance
s.display.viewdist = 75; 

% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;

