function s=pldapsClassDefaultParameters(s)
 if nargin<1
	s=struct;
 end

%s.	.
%s.	behavior.
%s.	behavior.	reward.
 s.	behavior.	reward.	defaultAmount = 0.3;
 s. behavior.   reward. manualAmount = 0.2;
 s. behavior.   reward. amount = [0.1 0.3 0.3 0.3];
 s. behavior.   reward. amountDelta = 0.05;
 s. behavior.   reward. propAmtIncorrect = 0.2;
 s. behavior.   reward. dacAmp = 10;
 s. behavior.   reward. nChannels = 3;
 s. behavior.   reward. channel. START = 3; %dac channel for reward delivery
 s. behavior.   reward. channel. LEFT = 2;
 s. behavior.   reward. channel. RIGHT = 1;
 s. behavior.   reward. channel. MIDDLE = 0;

%s. camera
 s. camera.     use = 0;
 s. camera.     cameraIP='172.30.11.XXX';
 s. camera.     udpRemotePort = 8000;
 s. camera.     udpLocalPort = 9000;

%s.	datapixx.
 s.	datapixx.	enablePropixxCeilingMount = false;
 s.	datapixx.	enablePropixxRearProjection = false;
 s.	datapixx.	LogOnsetTimestampLevel = 2;
 s.	datapixx.	use = true;
 s.	datapixx.	useAsEyepos = false;
 s.	datapixx.	useForReward = true;
 s. datapixx.   useAsPorts = true;
 s. datapixx.   useForStrobe = false;

%s.	datapixx.	adc.
 s.	datapixx.	adc.	bufferAddress = [ ];
 s.	datapixx.	adc.	channelGains = 1;
 s.	datapixx.	adc.	channelMapping = 'datapixx.adc.ports'; %alternatively: cell array
 s.	datapixx.	adc.	channelModes = 0;
 s.	datapixx.	adc.	channelOffsets = 0;
 s.	datapixx.	adc.	channels = [2 4 6 8];
 s.	datapixx.	adc.	maxSamples = 0;
 s.	datapixx.	adc.	numBufferFrames = 600000;
 s.	datapixx.	adc.	srate =1000;
 s.	datapixx.	adc.	startDelay = 0;
 s.	datapixx.	adc.	XEyeposChannel = [ ];
 s.	datapixx.	adc.	YEyeposChannel = [ ];
 
%s. datapixx.   dac.
 s. datapixx.   dac.    sampleRate = 1000;
 

%s.	datapixx.	GetPreciseTime.
 s.	datapixx.	GetPreciseTime.	maxDuration = [ ];
 s.	datapixx.	GetPreciseTime.	optMinwinThreshold = [ ];
 s.	datapixx.	GetPreciseTime.	syncmode = [ ];

%s.	display.
 s.	display.	bgColor = [ 0.5000    0.5000    0.5000 ];
 s.	display.	colorclamp = 0;
 s.	display.	destinationFactorNew = 'GL_ONE_MINUS_SRC_ALPHA';
 s.	display.	displayName = 'defaultScreenParameters';
 s.	display.	forceLinearGamma = false;
 s.	display.	heightcm = 29;
 s.	display.	normalizeColor = 1;
 s.	display.	screenSize = [0 0 1920 1080];
 s.	display.	scrnNum = 1;
 s.	display.	sourceFactorNew = 'GL_SRC_ALPHA';
 s.	display.	stereoFlip = [ ];
 s.	display.	stereoMode = 0;
 s. display.	switchOverlayCLUTs = false;
 s.	display.	useOverlay = 1;
 s.	display.	viewdist = 75;
 s.	display.	widthcm = 52;
 s. display.    enableBacklight = true;

%s.	display.	movie.
 s.	display.	movie.	create = false;
 s.	display.	movie.	dir = [ ];
 s.	display.	movie.	file = [ ];
 s.	display.	movie.	frameRate = [ ];
 s.	display.	movie.	height = [ ];
 s.	display.	movie.	options = ':CodecType=x264enc :EncodingQuality=1.0';
 s.	display.	movie.	width = [ ];

%s.	eyelink.
 s.	eyelink.	buffereventlength = 30;
 s.	eyelink.	buffersamplelength = 31;
 s.	eyelink.	calibration_matrix = [];
 s.	eyelink.	collectQueue = true;
 s.	eyelink.	custom_calibration = false;
 s.	eyelink.	custom_calibrationScale = 0.2500;
 s.	eyelink.	saveEDF = false;
 s.	eyelink.	use = false;
 s.	eyelink.	useAsEyepos = false;

%s.	git.
 s.	git.	use = false;
  
%s. led.
 s. led.    channel = 24;
 s. led.    use = 1;
 
%s.	mouse.
 s.	mouse.	use = false;
 s.	mouse.	useAsEyepos = false;
 s. mouse.  useAsPort = false;
 s. mouse.  virtualPortRadius = 20;

%s.	newEraSyringePump.
 s.	newEraSyringePump.	alarmMode = 1;
 s.	newEraSyringePump.	allowNewDiameter = false;
 s.	newEraSyringePump.	diameter = 38;
 s.	newEraSyringePump.	lowNoiseMode = 0;
 s.	newEraSyringePump.	port = '/dev/cu.usbserial';
 s.	newEraSyringePump.	rate = 2900;
 s.	newEraSyringePump.	use = false;

%s.	pldaps.
 s.	pldaps.	eyeposMovAv = 1;
 s.	pldaps.	finish = Inf;
 s.	pldaps.	goodtrial = 0;
 s.	pldaps.	iTrial = 1;
 s.	pldaps.	maxPriority = true;
 s.	pldaps.	maxTrialLength = 300;
 s.	pldaps.	nosave = false;
 s.	pldaps.	pass = false;
 s.	pldaps.	quit = 0;
 s.	pldaps.	save.	initialParametersMerged = 1;
 s.	pldaps.	save.	mergedData = 0;
 s.	pldaps.	save.	v73 = 0;
 s.	pldaps.	trialMasterFunction = 'runTrial';
 s.	pldaps.	useFileGUI = false;

%s.	pldaps.	dirs.
 s.	pldaps.	dirs.	data = '~/pldapsData';
 s.	pldaps.	dirs.	wavfiles = '~/PLDAPSNL/beepsounds';

%s.	pldaps.	draw.
%s.	pldaps.	draw.	cursor.
 s.	pldaps.	draw.	cursor.	use = false;

%s.	pldaps.	draw.	eyepos.
 s.	pldaps.	draw.	eyepos.	use = false;

%s.	pldaps.	draw.	framerate.
 s.	pldaps.	draw.	framerate.	location = [ -30   -10 ];
 s.	pldaps.	draw.	framerate.	nSeconds = 3;
 s.	pldaps.	draw.	framerate.	show = true;
 s.	pldaps.	draw.	framerate.	size = [ 20     5 ];
 s.	pldaps.	draw.	framerate.	use = true;
 s. pldaps. draw.   framerate.  rescaleY = false;

%s.	pldaps.	draw.	grid.
 s.	pldaps.	draw.	grid.	use = false;

%s.	pldaps.	draw.	photodiode.
 s.	pldaps.	draw.	photodiode.	everyXFrames = 17;
 s.	pldaps.	draw.	photodiode.	location = 1;
 s.	pldaps.	draw.	photodiode.	use = 0;
 
%s.	pldaps.	draw.	ports.
 s.	pldaps.	draw.	ports.	show = true;
 

%s. pldaps. draw.   reward.
 s. pldaps. draw.   reward. show = true;
 s. pldaps. draw.   reward. verbose = false; 
 
%s.	pldaps.	pause.
 s.	pldaps.	pause.	preExperiment = 0;
 s.	pldaps.	pause.	type = 1;

%s.	plexon.
%s.	plexon.	spikeserver.
 s.	plexon.	spikeserver.	continuous = false;
 s.	plexon.	spikeserver.	eventsonly = false;
 s.	plexon.	spikeserver.	remoteip = 'xx.xx.xx.xx';
 s.	plexon.	spikeserver.	remoteport = 3333;
 s.	plexon.	spikeserver.	selfip = 'xx.xx.xx.xx';
 s.	plexon.	spikeserver.	selfport = 3332;
 s.	plexon.	spikeserver.	use = 0;

%s. ports.
 s. ports.   use = true;
 s. ports.   nPorts = 4;
 s. ports.   movable = true;
 s. ports.   adc.  portMapping = 'datapixx.adc.ports'; %adc channels for port contact
 s. ports.   adc.  portThreshold = 2;
 s. ports.   adc.  portAvg = 0;
 s. ports.   dio.  channel. LEFT = 2; %dio channels to move ports
 s. ports.   dio.  channel. MIDDLE = 3;
 s. ports.   dio.  channel. RIGHT = 1;
 
%s.	session.
 s.	session.	experimentFile = [ ];

%s.	sound.
 s.	sound.	deviceid = [ ];
 s.	sound.	use = true;
 s. sound.  usePsychPortAudio = 0;
 s. sound.  volume = 0.25;
end