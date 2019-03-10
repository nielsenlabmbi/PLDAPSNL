function s = plain3_generalSettings

<<<<<<< Updated upstream
s.	newEraSyringePump.	use = [0 0 0];

%view params
% s.stimulus.baseline = 0;
% s.stimulus.lickdelay = 0.5;
% s.stimulus.forceCorrect_delay = 0.5;
% s.stimulus.duration.ITI = 1;
% s.stimulus.stimON = 0;
% s.stimulus.waitTime = 0;
% s.stimulus.fracInstruct = 1;

=======
>>>>>>> Stashed changes
%turn adc channels off
s.datapixx.useAsPorts = 0;
% s.datapixx.useAsEyePos = 1;
s.datapixx.adc.channels = [];

%turn mouse input on
s.mouse.useAsPort = 1;
s.mouse.use = 1;

%turn saving off
s.pldaps.nosave = 1;