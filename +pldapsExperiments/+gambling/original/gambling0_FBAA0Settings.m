function s = gambling0_FBAA0Settings

%general stimulus parameters
s.display.viewdist = 75; %viewing distance in cm (about halfway point)
s.display.bgColor = [0 0 0];

%reward steps
s.stimulus.intensity = [0 0.2 0.4 0.6 0.8 1];
s.stimulus.reference = [0 0.2 0.4 0.6 0.8 1];

s.stimulus.forceCorrect = 0;

%run/condition specific parameters
s.stimulus.runtype='pseudo'; %or block
s.stimulus.blocklength=2; %only used in blocks

%add camera
s.camera.use=1;
% 

% 
% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
% 
% %turn saving off
% s.pldaps.nosave = 1;
% 
% %turn off camera
% s.camera.use = 0;


