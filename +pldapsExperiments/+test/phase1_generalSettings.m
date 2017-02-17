function s = phase1_generalSettings

%turn adc channels off
s.datapixx.useAsPorts = 0;
s.datapixx.adc.channels = [];

%turn mouse input on
s.mouse.useAsPort = 1;
s.mouse.use = 1;

%turn saving off
s.pldaps.nosave = 1;

%misc
s.stimulus.baseline = 2;
s.stimulus.lickdelay = 1;

%ports
 s. ports.   nPorts = 3;