function s = dots_FBAA6Settings_free
% % turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
%s. behavior.   reward. amount = [0.1 0.35 0.375 0.35];
s. behavior.   reward. amount = [0.1 0.2 0.2 0.2];
s.	newEraSyringePump.	use = [1 1 0 0];
%set orientation and offsets
s.stimulus.dotSize = 1.5;
s.stimulus.nrDots = 100;
s.stimulus.fractionBlack = 0.5;
s.stimulus.dotCoherence = [0.1 0.2 0.4 0.6 0.8];
s.stimulus.dotSpeed = 0.4;
s.stimulus.dotLifetime = [240];
s.stimulus.durStim = 60;
s.stimulus.frameRate = 120;

%set viewing parameters
s.stimulus.baseline = 0.2;
s.stimulus.lickdelay = 1.3;
s.stimulus.duration.ITI = 1.5;
s.stimulus.stimON = 0.2;
s.stimulus.waitTime = 0;

%set instructive trials
s.stimulus.fracInstruct = 0.7;

%set up the viewing distance
s.display.viewdist = 75; 
% %add camera
s.camera.use=1;
% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;

