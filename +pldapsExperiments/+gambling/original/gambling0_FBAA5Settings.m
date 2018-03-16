function s = gambling_FBAA5Settings

%general stimulus parameters
s.display.viewdist = 75; %viewing distance in cm (about halfway point)
s.display.bgColor = [0 0 0];

%reward steps
s.stimulus.intensity = 1;%[0.2 0.4 0.6 0.8 1];
s.stimulus.reference = 0;

s.stimulus.forceCorrect = 1;
%run/condition specific parameters
s.stimulus.runtype='pseudo'; %or block
s.stimulus.blocklength=2; %only used in blocks
% % 
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



