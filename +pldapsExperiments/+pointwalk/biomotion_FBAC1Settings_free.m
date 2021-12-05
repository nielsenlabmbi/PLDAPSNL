function s = biomotion_FBAC1Settings_free
% % turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
%s. behavior.   reward. amount = [0.1 0.35 0.375 0.35];
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
s.stimulus.dotSize = 1.5;
s.display.bgColor = [0 0 0]; 
s.stimulus.framesPerMovie=220;
s.stimulus.direction = [0 180];
s.stimulus.movieId = [12, 14, 100, 15]; %current sets
%s.stimulus.speed = [0 1 2]; %0 in place, 1 fast, 2 slow
%s.stimulus.dotCoherence=100;
%this will be dot speed in +/- x position
s.stimulus.dotdistance = [{5},{4}, {3}, {2}, {1}, {0}, {[ 5 4 3 2 1 0]}]; %]; %[0.2 0.4 0.6 0.8 1];





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