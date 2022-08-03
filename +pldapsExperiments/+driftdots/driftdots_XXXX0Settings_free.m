function s = driftdots_XXXX0Settings_free


% % turn saving off
% s.pldaps.nosave = 1;

%set reward amounts
%s. behavior.   reward. amount = [0.1 0.35 0.375 0.35];
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];



%use this to change how close or far apart dots will appear
%10 = 10 columns more space; 20 = 20 columns less space etc
%must be even integer
s.stimulus.columnspacing = 16; %10, 20, 30, 40 
s.stimulus.dotSize = 1.5;

%closer dot spacing needs lower dotSize

s.stimulus.nrDots = 100;

%set background color
s.display.bgColor = [.5 .5 .5]; 



%s.stimulus.dotCoherence =  [{[1]},{[1 0.8 0.6 0.4 0.2]}]; %[{[1 0.8]},{[1]},{[1 0.6]},{[1]},{[1 0.4]},{[1]},{[1 0.2]},{[1]}];


s.stimulus.dotSpeed = 1;
s.stimulus.durStim = 60;
s.stimulus.frameRate = 120;
s.stimulus.direction = [0 180];

%set viewing parameters
s.stimulus.baseline = 0.2;
s.stimulus.lickdelay = 1.3;
s.stimulus.duration.ITI = 1.5;
s.stimulus.stimON = 0.2;
s.stimulus.waitTime = 0;
s.stimulus.aperture = 0;
s.stimulus.stimRadius = 10;
s.stimulus.driftSpeed = .04;


%set up the viewing distance
s.display.viewdist = 75; 
% %add camera
%s.camera.use=1;

%THANK YOU ERIKA FOR PLACING THE MOUSE INPUT HERE :)

% % %turn adc channels off
%  s.datapixx.useAsPorts = 0;
%  s.datapixx.adc.channels = [];
% % 
%  %turn mouse input on
%  s.mouse.useAsPort = 1;
%  s.mouse.use = 1;