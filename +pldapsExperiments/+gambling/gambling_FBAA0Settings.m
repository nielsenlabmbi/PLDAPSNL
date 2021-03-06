function s = gambling_FBAA0Settings

%general stimulus parameters
s.display.viewdist = 75; %viewing distance in cm (about halfway point)

%reward steps
s.stimulus.gambleAmt = 0.3; % could be vector
s.stimulus.fixedAmt = 0.15;
s.stimulus.fixedPort = 1; %fix the right side (could be vector instead)
s.stimulus.gamblePort = 2; %gamble the left side (could be a vector)
s.stimulus.probability = 0.1; 
s.stimulus.forceCorrect = 1;

s.	newEraSyringePump.	use = [1 1 0 0];

% %add camera
s.camera.use=1;
s.audio.use = 1;
% % 

% %% Debugging case%%% 
% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% % 
% % turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
% 
% %turn saving off
% s.pldaps.nosave = 1;
% 
% %turn off camera
% s.camera.use = 0;
% %%%%%%%%%%%%%%%%%%%%%



%run/condition specific parameters
s.stimulus.runtype='pseudo'; %or block
%s.stimulus.blocklength=2; %only used in blocks