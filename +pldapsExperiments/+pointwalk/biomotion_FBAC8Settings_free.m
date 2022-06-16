function s = biomotion_FBAC8Settings_free
% % turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
%s. behavior.   reward. amount = [0.1 0.35 0.375 0.35];
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
s.stimulus.dotSize = 1.5;

s.display.bgColor = [0 0 0]; 
s.stimulus.framesPerMovie=220;
s.stimulus.direction = [0 180];
s.stimulus.movieId = [15, 335, 14, 336];
%s.stimulus.speed = [0 1 2]; %0 in place, 1 fast, 2 slow
%s.stimulus.dotCoherence=100;
%use this for biomotion_trial
%s.stimulus.dotdistance = [{5},{4}, {3}, {2}, {1}, {[ 5 4 3 2 1]}]; %]; %[0.2 0.4 0.6 0.8 1];


s.stimulus.nrDots = [{[0]}, {[5]}, {[10]}, {[15]}, {[20]}, {[40]}, {[0 5 10 15 20 40]}];

s.stimulus.ferretdotSize = 1.5;
s.stimulus.stretchFactor = 2;

%use for sinusoidalscript
s.stimulus.dotdistance = [5];
s.stimulus.phase_coherence = [{[1]}, {[0.8]}, {[0.6]}, {[0.4]}, {[0.2]}, {[1 .8 .6 .4 .2]}];
s.stimulus.dotSpeed =[0.6];
s.stimulus.fractionBlack = 0;
s.stimulus.dotLifetime = [3];


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