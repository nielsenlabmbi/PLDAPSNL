function s = plain4

%set reward amounts
s. behavior.   reward. amount = [0.06 0.06 0.06];
s.behavior.reward.pulseFreq = 3;
s.behavior.reward.pulseInt = 0.2;
s.behavior.reward.amountDelta = 0.01;

%set viewing parameters
s.stimulus.baseline = 0;
s.stimulus.lickdelay = 1.5;
s.stimulus.forceCorrect_delay = 0.5;
s.stimulus.duration.ITI = 2;
s.stimulus.stimON = 0;
s.stimulus.waitTime = 0;

%set instructive trials
s.stimulus.fracInstruct = 0.2;

%set up the viewing distance
s.display.viewdist = 45; 


%turn adc channels off
s.datapixx.useAsPorts = 0;
%s.datapixx.adc.channels = [];
s.datapixx.useAsEyePos = 1;
%turn mouse input on
s.mouse.useAsPort = 1;
s.mouse.use = 1;

%turn saving off
%s.pldaps.nosave = 1;

%ports
 s. ports.   nPorts = 3;