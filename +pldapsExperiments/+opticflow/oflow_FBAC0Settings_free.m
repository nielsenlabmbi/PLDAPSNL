function s = oflow_FBAC6Settings_free
% % turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
%s. behavior.   reward. amount = [0.1 0.35 0.375 0.35];
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
s.stimulus.dotSize = 1;
s.stimulus.nrDots = 200;
s.stimulus.stimRadius=30;
s.display.bgColor = [0 0 0]; 
s.stimulus.dotCoherence = [{1},{[1 0.8]}, {[1 0.8 0.6 0.5 0.4]}]; %[0.2 0.4 0.6 0.8 1];
s.stimulus.dotSpeed = 0.3;
s.stimulus.dotLifetime = 60;
s.stimulus.durStim = 60;
s.stimulus.frameRate = 120;
s.stimulus.direction = [0 180];





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

