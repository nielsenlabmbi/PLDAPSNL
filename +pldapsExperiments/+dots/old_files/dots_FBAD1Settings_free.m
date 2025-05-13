function s = dots_FBAD1Settings_free

%MALE

% % turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
%s. behavior.   reward. amount = [0.1 0.35 0.375 0.35];
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
%set orientation and offsets
s.stimulus.dotSize = 1.5;
s.stimulus.nrDots = 100;
%s.stimulus.nrDots =  [{80}, {60}, {40}, {20}, {10}, {[80 60 40 20 10]}];
%set background color, wait color, and dot color 
s.display.bgColor = [0 0 0]; 
s.stimulus.fractionBlack = 0;


%this progression is only full coherence or a mixed bag of all coherences
%s.stimulus.dotCoherence =  [{[1]},{[1 0.8 0.6 0.4 0.2]}]; %[{[1 0.8]},{[1]},{[1 0.6]},{[1]},{[1 0.4]},{[1]},{[1 0.2]},{[1]}];

%this progression is above, but adds a new bag of a singular threshold
%this continues as a cascade down until all the thresholds are represented
%can always cut and adjust
s.stimulus.dotCoherence =  [{[1]}, {[0.8]}, {[0.6]}, {[0.4]}, {[0.2]}, {[1 0.8 0.6 0.4 0.2]}];
%s.stimulus.dotCoherence =  [{[1]}, {[0.8]}, {[0.6]}, {[1 0.8 0.6 0.4 0.2]}];
%s.stimulus.dotCoherence =  [{[1]}, {[0.8]}, {[0.6]}, {[0.4]}, {[1 0.8 0.6 0.4 0.2]}];
%s.stimulus.dotCoherence =  1;


%this progression is a cascade mix, add coherence to full coherence and
%bounce within that realm. It will oscilate back to a full coherence only
%on space shift. will also have to keep track of length
%s.stimulus.dotCoherence =  [{[1 0.8]},{[1]},{[1 0.6]},{[1]},{[1 0.4]},{[1]},{[1 0.2]},{[1]}];
%s.stimulus.dotCoherence =  [{[1 0.8]},{[1]},{[1 0.6]}];

s.stimulus.dotSpeed = 0.6;
s.stimulus.dotLifetime = [3];
s.stimulus.durStim = 60;
s.stimulus.frameRate = 120;
s.stimulus.direction = [0 180];

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
