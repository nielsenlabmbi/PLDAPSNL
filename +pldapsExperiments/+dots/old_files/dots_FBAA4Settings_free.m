function s = dots_FBAA4Settings_free
% % turn saving off
% s.pldaps.nosave = 1;
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];

%s.	newEraSyringePump.	use = [1 1 0 0];
%set reward amounts
%s. behavior.   reward. amount = [0.1 0.2 0.2 0.2];
%s.behavior.reward.amountDelta = 0.03;
%[0.1 0.3 0.3 0.3];

%set orientation and offsets
s.stimulus.dotSize = 1.5;
s.stimulus.nrDots = 100;
s.stimulus.fractionBlack = 0.5;
s.stimulus.dotCoherence = [0.05 0.1 0.2 0.5 1];
s.stimulus.dotSpeed = 0.4;
s.stimulus.dotLifetime = [240];
s.stimulus.durStim = 240;
s.stimulus.frameRate = 120;

%set viewing parameters
s.stimulus.baseline = 0.2;
s.stimulus.lickdelay = 1.3;
s.stimulus.duration.ITI = 1.5;
s.stimulus.stimON = 0.2;
s.stimulus.waitTime = 0;
s.	datapixx.	adc.	channels = [2 4 6];
%set up the viewing distance
s.display.viewdist = 75; 
% %add camera
%s.camera.use=1;
% 
% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;

