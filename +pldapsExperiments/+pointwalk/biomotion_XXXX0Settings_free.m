function s = biomotion_XXXX0Settings_free
% % turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
%s. behavior.   reward. amount = [0.1 0.35 0.375 0.35];
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
s.stimulus.dotSize = 1.5;
s.stimulus.ferretdotSize = 1.5;
%s.stimulus.nrDots = 100;
s.stimulus.stretchFactor = 2;

s.stimulus.nrDots = [{[20]}, {[5]}, {[10]}, {[15]}, {[20]}, {[40]}, {[0 5 10 15 20 40]}];
s.display.bgColor = [0 0 0]; 
s.stimulus.framesPerMovie= [220, 72];
s.stimulus.direction = [0 180];
s.stimulus.movieId = [336, 14, 335, 15]; %14 15 329]; %current working set
%s.stimulus.speed = [0 1 2]; %0 in place, 1 fast, 2 slow
%s.stimulus.dotCoherence=100;
%this will be dot speed in +/- x position
%s.stimulus.dotdistance = [{5},{4}, {3}, {2}, {1}, {0}, {[ 5 4 3 2 1 0]}]; %]; %[0.2 0.4 0.6 0.8 1];
s.stimulus.dotdistance = [5]; %]; %[5 4 3 2 1 ];


%.2 means 20% are out of phase (easy) 1 means 100% out of phase (hard)
s.stimulus.phase_coherence = [{[0]}, {[0.2]}, {[0.4]}, {[0.6]}, {[0.8]}, {[1]}, {[0 .2 .4 .6 .8 1]}];
%s.stimulus.phase_coherence = [{[1]}, {[0.8]}, {[0.6]}, {[0.4]}, {[0.2]}, {[1 .8 .6 .4 .2]}];
s.stimulus.dotSpeed =[0.6];
s.stimulus.fractionBlack = 0;
s.stimulus.dotLifetime = [3];
%use this to shift the percentage of ferret that is scrambled
s.stimulus.scrambled = [{[0]}, {[0.2]}, {[0.4]}, {[0.6]}, {[0.8]}, {[1]}, {[0 .2 .4 .6 .8 1]}];



%set up the viewing distance
s.display.viewdist = 75; 
% %add camera
%s.camera.use=1;


% %turn adc channels off
 s.datapixx.useAsPorts = 0;
 s.datapixx.adc.channels = [];
% 
% %turn mouse input on
 s.mouse.useAsPort = 1;
 s.mouse.use = 1;

