function s = dots_FBAA0Settings_free
% % turn saving off
% s.pldaps.nosave = 1;

s.	newEraSyringePump.	use = [1 1 0 0];
%set reward amounts
s. behavior.   reward. amount = [0.075 .15 .15 0.15];%[0.075 0.25 0.25 0.25];
s.behavior.reward.amountDelta = 0.03;

%set orientation and offsets
s.stimulus.dotSize = 1.5;
s.stimulus.nrDots = 100;
s.stimulus.fractionBlack = 0.5;
s.stimulus.dotCoherence = [0.2 0.4 0.6 0.8 1];
s.stimulus.dotSpeed = 0.4;
s.stimulus.dotLifetime = [240];
s.stimulus.durStim = 240;
s.stimulus.frameRate = 120;

%set up the viewing distance
s.display.viewdist = 75; 
% %add camera
s.camera.use=1;

% % %%% Debugging
% % turn adc channels off
% s.datapixx.useAsPorts = 0;
% % s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
% 
% % %turn saving off
% % s.pldaps.nosave = 1;
% 
% %don't use syringe pump
%  s.	newEraSyringePump.	use = [0 0 0 0];
% %turn off camera
% s.camera.use = 0;
