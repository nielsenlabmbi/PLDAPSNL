function s = plain3_ports

%turn adc channels on
s.datapixx.useAsPorts = 1;
s.datapixx.adc.channels = [1 3 5];

%turn mouse input off
s.mouse.useAsPort = 0;
s.mouse.use = 0;

%turn saving off
s.pldaps.nosave = 1;

%ports
 s. ports.   nPorts = 3;