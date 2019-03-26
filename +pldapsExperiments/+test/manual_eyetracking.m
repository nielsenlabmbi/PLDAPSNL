%% generic eye tracking script

%% wake viewpixx
sca;
% Get rid of the Psychtoolbox welcome screen, Close any open windows
Screen('Preference','VisualDebuglevel',3); 
Screen('Preference','SuppressAllWarnings',1);
% These commands ready the PTB motion server for the VIEWPixx 2-CLUT system
% This is the first step in setting up the image processing properties of 
% a window for the psychophysics toolbox
PsychImaging('PrepareConfiguration');
% Uses 32 bit precision in displaying colors, if hardware can not handle
% this with alpha blending, consider dropping to 16 bit precision or using
% 'FloatingPoint32BitIfPossible', to drop precision while maintaining 
% alpha blending.
PsychImaging('AddTask','General','FloatingPoint32BitIfPossible');
% This command adds the use of an overlay window, unlike the main window,
% the overlay window uses a color look-up table where 0 values are
% transparent, Overlay for Viewpixx is only supported in M16 mode
PsychImaging('AddTask','General','EnableDataPixxM16OutputWithOverlay');
% Applies a simple power-law gamma correction
PsychImaging('AddTask','FinalFormatting','DisplayColorCorrection','SimpleGamma');
% Now the image processing properties are set, open the stimulus window
[s.display.ptr s.display.screenRect] = PsychImaging('OpenWindow',1,[0 0 0]);
% Apply a gamma correction
PsychColorCorrection('SetEncodingGamma',s.display.ptr,1/2.2);
% Get the frame refresh rate of the stimulus window
s.frameRate = FrameRate(s.display.ptr);
% Get color look up tables for an overlay window
s.controlsColors = [
0      0      0      ;  % 0 first row does not count
1      1      1      ;  % 1 white
0.5    0.5    0.5    ;  % 2 gray
1      0      0      ;  % 3 red
0      1      0      ;  % 4 green
0      0      1      ;  % 5 blue
1      1      1      ]; % 6 white
s.subjectColors = [
0      0      0      ;  % 0 first row does not count
1      1      1      ;  % 1 white
0.5    0.5    0.5    ;  % 2 gray
0      0      0      ;  % 3 background
0      0      0      ;  % 4 background
0      0      0      ;  % 5 background
0      0      0      ]; % 6 background
s.controlsCLUT = [s.controlsColors; zeros(256-size(s.controlsColors,1),3)];
s.subjectCLUT = [s.subjectColors; zeros(256-size(s.subjectColors,1),3)];
% A COMBINED COLOR LOOK UP TABLE (CLUT) FOR THE VPIXX 2-CLUT SYSTEM
s.combinedCLUT = [s.subjectCLUT; s.controlsCLUT];
% Open the overlay window for writing to the window using the clut
s.overlay = PsychImaging('GetOverlayWindow',s.display.ptr);
% Load the CLUTs that were combined into the window, the VIEWPixx will use
% the first 256 values in the CLUT, the VIEWPixx DVI out will use the
% next 256 values.
Screen('LoadNormalizedGammaTable',s.display.ptr,s.combinedCLUT,2);
% Set the the PTB motion server to maximum priority
s.priorityLevel = MaxPriority(s.display.ptr);
% Set alpha blending functions for antialiasing
Screen(s.display.ptr,'BlendFunction',GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

% INITIALIZE THE VIEWPIXX FOR STIMULUS CONTROL AND DATA COLLECTION
% Open the viewpixx device for communication with Matlab
if ~Datapixx('isReady'), Datapixx('Open'); pause(.1); end
% Stop any pre-existing schedules, none should be running, just to be safe
Datapixx('StopAllSchedules');
% Enable the scanning backlight, in this mode back light modules sweep
% across the monitor similar to the way a CRT sweeps across a TV screen,
% briefly illuminating the LCD when at the correct color and hiding
% the LCD as it transitions from one color to another.
Datapixx('EnableVideoScanningBacklight');
% Enable the ability to query ADC voltages realtime, this reduces
% accuracy of scheduled collection by 5 micro-seconds, but is worth the
% small trade-off in accuracy for real-time beam detection
Datapixx('EnableAdcFreeRunning');
% Initializes audio output of the Viewpixx
Datapixx('InitAudio');
% 64-sample sinewave in audio buffer--all tones will be sinewaves
Datapixx('WriteAudioBuffer',sin(2*pi*(1:64)/64));
% Write these changes to the Viewpixx
Datapixx('RegWrRd');

Screen('FillRect',s.overlay,0);
Screen('FillRect',s.display.ptr,0);
Screen('Flip',s.display.ptr);


%% set parameters
s.color = 1;
s.size = [-40 -40 40 40];
s.direction = 0;%[0 90 180 270];
s.viewdist = 25;
s.distDeg = 5;
s.pursuit = 1;% 0 is flash
s.speed = 0.2;%pursuit speed in degrees

s.wait = 1;
s.stimdur = 1;
% 
% s.datapixx.useAsEyepos = 1;
%  s.	pldaps.	draw.	eyepos.	use = 1;
%  s.	pldaps.	draw.	eyepos.	show = 1;
s.ports.use = 0;
s.ports.movable = 0;
s.datapixx.use = 1;

%% conversions
s.ctr = [960 540 960 540];
s.screenwidth = 52;
s.screenwidthdeg = 2*atan2((s.screenwidth/2),s.viewdist)*180/pi;
s.screenwidthpix = 1920;
s.degperpix = s.screenwidthdeg/s.screenwidthpix;
s.pixperdeg = 1/s.degperpix;

s.dFrame = round(s.speed*s.pixperdeg);
s.limits = round((s.ctr + s.size) + (s.pixperdeg*s.distDeg).*[-1 -1 1 1]);

limits = [420 0 1500 1080];
if s.limits(1) < limits(1) || s.limits(2) < limits(2) || s.limits(3) > limits(3) || s.limits(4) > limits(4)
    warning('End value is off-screen');
end
%% run stimulus
s.frameI = 0;
s.state = 1;

% initial stimulus
s.iniColor= s.color;
s.ctr = [960 540 960 540];
s.iniSize = s.ctr + s.size;
timeNow = now;
Screen('FillRect',s.display.ptr,s.iniColor,s.iniSize);
Screen('Flip',s.display.ptr);
if now > timeNow + s.wait;
    s.state = 2;
end
% move
timeNow = now;
while s.state == 2
    if s.pursuit == 1
        %might need a while look here? unclear
        if s.frameI == 0
            randpos = s.iniSize;
        else
            randpos = s.pos{s.stimulus.frameI};
        end
        s.frameI = s.frameI+1;
        xproj=cos(s.direction*pi/180);
        yproj=-sin(s.direction*pi/180);
        shift = repmat([s.dFrame*xproj s.dFrame*yproj],1,2);
        randpos = randpos + shift;
        limits = s.limits;
        
        if randpos(1) < limits(1) || randpos(2) < limits(2) || randpos(3) > limits(3) || randpos(4) > limits(4)
            %randpos = randpos - shift;
            s.state = 3;
        end
        
        %     if randpos(1) < 420 || randpos(3) > 1500 || randpos(2) < 0 || randpos(4) > 1080
        %         randpos = randpos - shift;
        %     end
        s.pos{s.stimulus.frameI} = randpos;
        Screen('FillRect',s.display.ptr,s.color,s.pos{s.stimulus.frameI+1});
        Screen('Flip',s.display.ptr);
        
    else
        %s.stimulus.dFrame = 500;
        s.dFrame = (s.limits(4) - s.limits(2))/2 - unique(abs(s.size));
        s.frameI = 1;
        randpos = s.iniSize;
        xproj=cos(s.direction*pi/180);
        yproj=-sin(s.direction*pi/180);
        shift = repmat([s.dFrame*xproj s.dFrame*yproj],1,2);
        randpos = randpos + shift;
        
        s.pos{1} = randpos;
        s.pos{s.frameI} = randpos;
        Screen('FillRect',s.display.ptr,s.color,s.pos{s.frameI});
        Screen('Flip',s.display.ptr);
        if now > timeNow + s.stimdur;
            s.state = 3;
        end
    end
    if s.state == 3
        Screen('FillRect',s.overlay,0);
        Screen('FillRect',s.display.ptr,0);
        Screen('Flip',s.display.ptr);
    end
end


%% close datapixx, close screen
sca
if(s.datapixx.use)
    %stop adc data collection if requested
    pds.datapixx.adc.stop(p);
    
    %stop din data collection
    pds.datapixx.din.stop(p);
    
    status = PsychDataPixx('GetStatus');
    if status.timestampLogCount
        s.datapixx.timestamplog = PsychDataPixx('GetTimestampLog', 1);
    end
end
%%
switch s.state
    case 1
        Screen('FillRect',s.display.ptr,s.iniColor,s.iniSize);
        Screen('Flip',s.display.ptr);
        if now > timeNow + s.wait;
            s.state = 2;
        end
    case 2
        % include a tone to indicate stimulus moved?
        % pds.audio.playDatapixxAudio(p,'reward_short');
        if s.pursuit == 1
            %might need a while look here? unclear
            if s.frameI == 0
                randpos = s.iniSize;
            else
                randpos = s.pos{s.stimulus.frameI};
            end
            s.frameI = s.frameI+1;
            xproj=cos(s.direction*pi/180);
            yproj=-sin(s.direction*pi/180);
            shift = repmat([s.dFrame*xproj s.dFrame*yproj],1,2);
            randpos = randpos + shift;
            limits = s.limits;
            
            if randpos(1) > limits(1) || randpos(2) > limits(2) || randpos(3) > limits(3) || randpos(4) > limits(4)
                %randpos = randpos - shift;
                s.state = 3;
            end
            
            %     if randpos(1) < 420 || randpos(3) > 1500 || randpos(2) < 0 || randpos(4) > 1080
            %         randpos = randpos - shift;
            %     end
            s.pos{s.stimulus.frameI} = randpos;
            Screen('FillRect',s.display.ptr,s.color,s.pos{s.stimulus.frameI});
            Screen('Flip',s.display.ptr);

        else
            %s.stimulus.dFrame = 500;
            s.dFrame = (s.limits(4) - s.limits(2))/2 - unique(abs(s.size));
            s.frameI = 1;
            randpos = s.iniSize;
            xproj=cos(s.direction*pi/180);
            yproj=-sin(s.direction*pi/180);
            shift = repmat([s.dFrame*xproj s.dFrame*yproj],1,2);
            randpos = randpos + shift;
            
            s.pos{1} = randpos;
            s.pos{s.frameI} = randpos;
            Screen('FillRect',s.display.ptr,s.color,s.pos{s.frameI});
            Screen('Flip',s.display.ptr);
            timeNow = now;
            if now > timeNow + s.stimdur;
                s.state = 3;
            end
        end
    case 3
        Screen('DrawingFinished', s.display.ptr,0,0);
        Screen('FillRect',s.overlay,0);
        Screen('FillRect',s.display.ptr,0);
        Screen('Flip',s.display.ptr);
        
end