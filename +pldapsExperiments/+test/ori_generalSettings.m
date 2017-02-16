function s = ori_generalSettings

%turn adc channels off
s.datapixx.useAsPorts = 0;
s.datapixx.adc.channels = [];

%turn mouse input on
s.mouse.useAsPort = 1;
s.mouse.use = 1;

%turn saving off
s.pldaps.nosave = 1;

%set reward amounts
s. behavior.   reward. amount = [0.1 0.3 0.3 0.3];

%set orientation and offsets
s.stimulus.offsets = [10 20 30 45];
s.stimulus.angle = 0;
s.stimulus.sf = 0.25;
s.stimulus.range = 121;
s.stimulus.baseline = 1;
s.stimulus.stimON = 2;

%set up the viewing distance
s.display.viewdist = 75; 

%configure ports
 s.ports.use = true;
 s.ports.nports = 3;
 s.ports.movable = true;
 s.datapixx.adc.channels = [1 3 5];
