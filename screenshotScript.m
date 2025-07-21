%basic display script to get screen shots on PLDAPS rig

InitializeMatlabOpenGL(0,0); %second 0: debug level =0 for speed
Screen('Preference','VisualDebugLevel',3);
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange');
PsychImaging('AddTask', 'General', 'UseDataPixx');
PsychImaging('AddTask', 'General', 'FloatingPoint32Bit','disableDithering',1);
PsychImaging('AddTask', 'General', 'EnableDataPixxM16OutputWithOverlay');

[ptr, winRect]=PsychImaging('OpenWindow', 1, [0.5 0.5 0.5], [0 0 1920 1080], [], [], 0, 0);

%displayWidth = 2*atand(p.trial.display.widthcm/2/p.trial.display.viewdist);

%% below is the part that generates the stimuli
stimulus.shapeOffset=600; %offset of each stimulus to the side relative to center
stimulus.shapeScale=150; %scale factor for shape (in pixels)

stimulus.shapeSizeP=0.5;  %was: {1;[0.5 1 2]};%randomly scale shape size
stimulus.shapeSizeN=1;  %was: {1;[0.5 1 2]};%randomly scale shape size

centerPosX=1920/2;
centerPosY=800;

%positive shape - star
shapeCoordP=[0 1
            0.25 0.25
            1 0.25
            0.4 -0.25
            0.7 -1
            0 -0.5
            -0.7 -1
            -0.4 -0.25
            -1 0.25
            -0.25 0.25];
shapeCoordP=shapeCoordP*stimulus.shapeScale;
shapeCoordP=shapeCoordP*stimulus.shapeSizeP;
shapeCoordP(:,1)=shapeCoordP(:,1)+centerPosX-stimulus.shapeOffset;
shapeCoordP(:,2)=shapeCoordP(:,2)+centerPosY;

%negative shape - square
shapeCoordN=[-0.7 0.7
            0.7 0.7
            0.7 -0.7
            -0.7 -0.7];
shapeCoordN=shapeCoordN*stimulus.shapeScale;
shapeCoordN=shapeCoordN*stimulus.shapeSizeN;
shapeCoordN(:,1)=shapeCoordN(:,1)+centerPosX+stimulus.shapeOffset;
shapeCoordN(:,2)=shapeCoordN(:,2)+centerPosY;

Screen('FillPoly',ptr,[1 1 1],shapeCoordP);
%Screen('FillPoly',ptr,[1 1 1],shapeCoordN);

%% flip screen
Screen('Flip',ptr);

%get image
imgArray=Screen('GetImage',ptr);

%close psychtoolbox
%KBStrokeWait;
%Screen('CloseAll');


