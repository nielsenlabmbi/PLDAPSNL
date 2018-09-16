function p = run(p)
%run    run a new experiment for a previuously created pldaps class
% p = run(p)
% PLDAPS (Plexon Datapixx PsychToolbox) version 4.1
%       run is a wrapper for calling PLDAPS package files
%           It opens the PsychImaging pipeline and initializes datapixx for
%           dual color lookup tables.
% 10/2011 jly wrote it (modified from letsgorun.m)
% 12/2013 jly reboot. updated to version 3 format.
% 04/2014 jk  moved into a pldaps class; adapated to new class structure

%TODO:
% one unified system for modules, e.g. moduleSetup, moduleUpdate, moduleClose
% make HideCursor optional
% TODO:reset class at end of experiment or mark as recorded, so I don't
% run the same again by mistake

try
    %% Setup and File management
    % Enure we have an experimentSetupFile set and verify output file
    
    
    % pick YOUR experiment's main CONDITION file-- this is where all
    % expt-specific stuff emerges from
    if isempty(p.defaultParameters.session.experimentSetupFile)
        [cfile, cpath] = uigetfile('*.m', 'choose condition file', [base '/CONDITION/debugcondition.m']); %#ok<NASGU>
        
        dotm = strfind(cfile, '.m');
        if ~isempty(dotm)
            cfile(dotm:end) = [];
        end
        p.defaultParameters.session.experimentSetupFile = cfile;
    end
    
    p.defaultParameters.session.initTime=now;
    
    if ~p.defaultParameters.pldaps.nosave
        p.defaultParameters.session.dir = p.defaultParameters.pldaps.dirs.data;
        p.defaultParameters.session.file = [p.defaultParameters.session.subject datestr(p.defaultParameters.session.initTime, 'yyyymmdd') p.defaultParameters.session.experimentSetupFile datestr(p.defaultParameters.session.initTime, 'HHMM') '.PDS'];
        
        if p.defaultParameters.pldaps.useFileGUI
            [cfile, cdir] = uiputfile('.PDS', 'specify data storage file', fullfile( p.defaultParameters.session.dir,  p.defaultParameters.session.file));
            if(isnumeric(cfile)) %got canceled
                error('pldaps:run','file selection canceled. Not sure what the correct default bevaior would be, so stopping the experiment.')
            end
            p.defaultParameters.session.dir = cdir;
            p.defaultParameters.session.file = cfile;
        end
    else
        p.defaultParameters.session.file='';
        p.defaultParameters.session.dir='';
    end
    
    
    %% Open PLDAPS windows and other setup
    % Open PsychToolbox Screen
    p = openScreen(p);
    
    % add trialMem structure (holds numbers from trial to trial)
    p.trialMem=struct;
    
    % Setup PLDAPS experiment condition
    p.defaultParameters.pldaps.maxFrames=p.defaultParameters.pldaps.maxTrialLength*p.defaultParameters.display.frate;
    feval(p.defaultParameters.session.experimentSetupFile, p);
    
    %for all of the setup stuff following below, the necessary if clauses
    %that determine whether a particular setup is needed are in the setup
    %file itself
    
    %
    % Setup Photodiode stimuli
    %-------------------------------------------------------------------------%
    p = makePhotodiodeRect(p);
    
    % Tick Marks
    %-------------------------------------------------------------------------%
    p = initTicks(p);
        
    % Response ports
    %-------------------------------------------------------------------------%
    p = pds.ports.initPortStatus(p);
    p = pds.ports.makePortsPos(p);
           
    % Git
    %-------------------------------------------------------------------------%
    %get and store changes of current code to the git repository
    p = pds.git.setup(p);
    
    % Eyelink
    %-------------------------------------------------------------------------%
    p = pds.eyelink.setup(p);
          
    % Audio (this uses psychportaudio)
    %-------------------------------------------------------------------------%
    p = pds.audio.setup(p);
    
    % PLEXON
    %-------------------------------------------------------------------------%
    p = pds.plexon.spikeserver.connect(p);
    
    % REWARD
    %-------------------------------------------------------------------------%
    p = pds.behavior.reward.setup(p);
    p.trialMem.currentAmount=p.trial.behavior.reward.amount;
    
    % Datapixx
    %-------------------------------------------------------------------------%
    % Initialize Datapixx including dual CLUTS and timestamp
    % logging
    p = pds.datapixx.init(p);


    % Behavior camera
    %-------------------------------------------------------------------------%
    p = pds.behavcam.setupcam(p);
    
    
    % Two-photon
    %-------------------------------------------------------------------------%
    p = pds.sbserver.setup2P(p);
    
    % DAQ
    p = pds.daq_com.initialize_daq(p);
    
    % Keyboard
    %-------------------------------------------------------------------------%
    pds.keyboard.setup(p);
    
    % States
    %-------------------------------------------------------------------------%
    % Initialize LED state
    if p.trial.led.use == 1
        p.trial.led.state = 0;
    end
    
    % Initialize trial locking status
    p.trialMem.lock = 0;
    
    %% Last chance to check variables
    if(p.trial.pldaps.pause.type==1 && p.trial.pldaps.pause.preExperiment==true) %0=don't,1 is debugger, 2=pause loop
        p  %#ok<NOPRT>
        disp('Ready to begin trials. Type return to start first trial...')
        keyboard %#ok<MCKBD>
    end
    
    %% start experiment
    %%%%start recoding on all controlled components this in not currently done here
    % save timing info from all controlled components (datapixx, eyelink, this pc)
    p = beginExperiment(p);
    
    % disable keyboard
    ListenChar(2)
    HideCursor
    
    p.trial.flagNextTrial  = 0; % flag for ending the trial
    p.trial.iFrame     = 1;  % frame index
    
    %save defaultParameters as trial 0
    trialNr=0;
    p.trial.pldaps.iTrial=0;
    p.trial=mergeToSingleStruct(p.defaultParameters);
    result = saveTempFile(p);
    if ~isempty(result)
        disp(result.message)
    end
    
    
    levelsPreTrials=p.defaultParameters.getAllLevels();
    
    %% main trial loop %%
    while p.trial.pldaps.iTrial < p.trial.pldaps.finish && p.trial.pldaps.quit~=2
        
        if p.trial.pldaps.quit == 0
            
            %load parameters for next trial and lock defaultsParameters
            trialNr=trialNr+1;
            p.defaultParameters.addLevels(p.conditions(trialNr), {['Trial' num2str(trialNr) 'Parameters']});
            p.defaultParameters.setLevels([levelsPreTrials length(levelsPreTrials)+trialNr]);
            p.defaultParameters.pldaps.iTrial=trialNr;
            
            
            %it looks like the trial struct gets really partitioned in
            %memory and this appears to make some get (!) calls slow.
            %We thus need a deep copy. The superclass matlab.mixin.Copyable
            %is supposed to do that, but that is ver very slow, so we create
            %a manual deep copy by saving the struct to a file and loading it
            %back in.
            tmpts=mergeToSingleStruct(p.defaultParameters);
            save([p.trial.pldaps.dirs.data filesep 'TEMP' filesep 'deepTrialStruct'], 'tmpts');
            clear tmpts
            load([p.trial.pldaps.dirs.data filesep 'TEMP' filesep 'deepTrialStruct']);
            p.trial=tmpts;
            clear tmpts;
            
            p.defaultParameters.setLock(true);
            
            % run trial
            p = feval(p.trial.pldaps.trialMasterFunction,  p);
            
            %unlock the defaultParameters
            p.defaultParameters.setLock(false);
            
            %save tmp data
            result = saveTempFile(p);
            if ~isempty(result)
                disp(result.message)
            end
            
            if p.defaultParameters.pldaps.save.mergedData
                %store the complete trial struct to .data
                dTrialStruct = p.trial;
            else
                %store the difference of the trial struct to .data
                dTrialStruct=getDifferenceFromStruct(p.defaultParameters,p.trial);
            end
            p.data{trialNr}=dTrialStruct;
           
            
        else %dbquit ==1 is meant to be pause. should we halt eyelink, datapixx, etc?
            %create a new level to store all changes in,
            %load only non trial paraeters
            pause=p.trial.pldaps.pause.type;
            p.trial=p.defaultParameters;
            
            p.defaultParameters.addLevels({struct}, {['PauseAfterTrial' num2str(trialNr) 'Parameters']});
            p.defaultParameters.setLevels([levelsPreTrials length(p.defaultParameters.getAllLevels())]);
            
            if pause==1 %0=don't,1 is debugger, 2=pause loop
                ListenChar(0);
                ShowCursor;
                p.trial
                disp('Ready to begin trials. Type "dbcont" to start first trial...')
                pds.sbserver.shutter2P(p,'0'); %if collecting two photon data, blank the laser
                keyboard %#ok<MCKBD>
                p.trial.pldaps.quit = 0;
                ListenChar(2);
                HideCursor;
            elseif pause==2
                pauseLoop(p);
            end
            %             pds.datapixx.refresh(dv);
            
            %now I'm assuming that nobody created new levels,
            %but I guess when you know how to do that
            %you should also now how to not skrew things up
            allStructs=p.defaultParameters.getAllStructs();
            if(~isequal(struct,allStructs{end}))
                levelsPreTrials=[levelsPreTrials length(allStructs)]; %#ok<AGROW>
            end
        end
        
    end
    
    %make the session parameterStruct active
    p.defaultParameters.setLevels(levelsPreTrials);
    p.trial = p.defaultParameters;
    
    % return cursor and command-line control
    ShowCursor;
    ListenChar(0);
    Priority(0);
    
    %close other devices
    p = pds.eyelink.finish(p);
    p = pds.plexon.finish(p);
    if(p.defaultParameters.datapixx.use)
        %stop adc data collection if requested
        pds.datapixx.adc.stop(p);
        
        %stop din data collection
        pds.datapixx.din.stop(p);
        
        status = PsychDataPixx('GetStatus');
        if status.timestampLogCount
            p.defaultParameters.datapixx.timestamplog = PsychDataPixx('GetTimestampLog', 1);
        end
    end
    
    
    %turn LED off (has an internal check whether LED is in use)
    pds.LED.LEDOff(p);
    
    %close camera (if used)
    pds.behavcam.closecam(p);
    
    %close laser (if used)
    pds.sbserver.close2P(p);
    
    if ~p.defaultParameters.pldaps.nosave
        [structs,structNames] = p.defaultParameters.getAllStructs();
        
        PDS=struct;
        PDS.initialParameters=structs(levelsPreTrials);
        PDS.initialParameterNames=structNames(levelsPreTrials);
        if p.defaultParameters.pldaps.save.initialParametersMerged
            PDS.initialParametersMerged=mergeToSingleStruct(p.defaultParameters); %too redundant?
        end
        
        levelsCondition=1:length(structs);
        levelsCondition(ismember(levelsCondition,levelsPreTrials))=[];
        PDS.conditions=structs(levelsCondition);
        PDS.conditionNames=structNames(levelsCondition);
        PDS.data=p.data;
        PDS.functionHandles=p.functionHandles;
        if p.defaultParameters.pldaps.save.v73
            save(fullfile(p.defaultParameters.session.dir, p.defaultParameters.session.file),'PDS','-mat','-v7.3')
        else
            save(fullfile(p.defaultParameters.session.dir, p.defaultParameters.session.file),'PDS','-mat')
        end
    end
    
    
    if p.trial.display.movie.create
        Screen('FinalizeMovie', p.trial.display.movie.ptr);
    end
    Screen('CloseAll');
    
    sca;
    
catch me
    sca
    
    % return cursor and command-line control
    ShowCursor
    ListenChar(0)
    disp(me.message)
    
    nErr = size(me.stack);
    for iErr = 1:nErr
        fprintf('errors in %s line %d\r', me.stack(iErr).name, me.stack(iErr).line)
    end
    fprintf('\r\r')
    
    keyboard
end

end
%we are pausing, will create a new defaultParaneters Level where changes
%would go.
function pauseLoop(dv)
ShowCursor;
ListenChar(1);
while(true)
    %the keyboard chechking we only capture ctrl+alt key presses.
    [dv.trial.keyboard.pressedQ,  dv.trial.keyboard.firstPressQ]=KbQueueCheck(); % fast
    if dv.trial.keyboard.firstPressQ(dv.trial.keyboard.codes.Lctrl)&&dv.trial.keyboard.firstPressQ(dv.trial.keyboard.codes.Lalt)
        %D: Debugger
        if  dv.trial.keyboard.firstPressQ(dv.trial.keyboard.codes.dKey)
            disp('stepped into debugger. Type return to start first trial...')
            keyboard %#ok<MCKBD>
            
            %E: Eyetracker Setup
        elseif  dv.trial.keyboard.firstPressQ(dv.trial.keyboard.codes.eKey)
            try
                if(dv.trial.eyelink.use)
                    pds.eyelink.calibrate(dv);
                end
            catch ME
                display(ME);
            end
            
            %M: Manual reward
        elseif  dv.trial.keyboard.firstPressQ(dv.trial.keyboard.codes.mKey)
            %pds.behavior.reward.give(p);
            
            %P: PAUSE (end the pause)
        elseif  dv.trial.keyboard.firstPressQ(dv.trial.keyboard.codes.pKey)
            dv.trial.pldaps.quit = 0;
            ListenChar(2);
            HideCursor;
            break;
            
            %Q: QUIT
        elseif  dv.trial.keyboard.firstPressQ(dv.trial.keyboard.codes.qKey)
            dv.trial.pldaps.quit = 2;
            break;
            
            %X: Execute text selected in Matlab editor
        elseif  dv.trial.keyboard.firstPressQ(dv.trial.keyboard.codes.xKey)
            activeEditor=matlab.desktop.editor.getActive;
            if isempty(activeEditor)
                display('No Matlab editor open -> Nothing to execute');
            else
                if isempty(activeEditor.SelectedText)
                    display('Nothing selected in the active editor Widnow -> Nothing to execute');
                else
                    try
                        eval(activeEditor.SelectedText)
                    catch ME
                        display(ME);
                    end
                end
            end
            
            
        end %IF CTRL+ALT PRESSED
    end
    pause(0.1);
end

end
