function p = demo(p)
p = pdsDefaultTrialStructure(p); 

%some meaningfull understandable colors for the color scheme system
p = newsomedots.jonasDefaultColors(p);

%% Random numbers
p.trial.stimulus.rngs.sessionSeed=fix(1e6*sum(clock));
p.trial.stimulus.rngs.sessionRNG=RandStream(p.trial.stimulus.randomNumberGenerater, 'seed', p.trial.stimulus.rngs.sessionSeed);
if datenum(version('-date')) >= datenum('February 9, 2012') %strcmp(version, '7.14.0.739 (R2012a)')
    RandStream.setGlobalStream(p.trial.stimulus.rngs.sessionRNG);
else
    RandStream.setDefaultStream(p.trial.stimulus.rngs.sessionRNG); %#ok<SETRS>
end
p.trial.stimulus.rngs.trialSeeds = randi(2^32, [1e3 1]); %1e5

%% set the trial master function: the fucntion that get called once per trial
% dv.trial.pldaps.trialMasterFunction='runTrial'; %i.e. use the
% sytem integrated into pldaps with a secondary trial function that gets
% calles multiple times per frame
%% set the trial function: the function that get's call for each frame state
p.trial.pldaps.trialFunction='newsomedots.newsomedots';

%% behavior parameters 
%fixation window
p.trial.stimulus.fpWin     = p.trial.display.ppd*[4 4]; %in pixels
p.trial.stimulus.fixationXY = [0 0]; %center in pixels
%%reward
p.trial.behavior.reward.defaultAmount = 0.1; % units depends on reward system, typically either seconds, or ml

%% timing
p.trial.stimulus.preTrial = .0; %minimum time after trial start before fixation is accepted (in seconds) 
p.trial.stimulus.fixWait  = .8; %maximum time to wait untill initial Fixation in seconds

%% motion parameters  
%we have 5 motion states: 1: no dots shown, 2: dots on,
%stationary, 3: dots moving, 4: dots stationary again, 5: dots of
p.trial.stimulus.motionStateDuration = [100,200,3000,200,100]; %duration of each state in ms

p.trial.stimulus.thetas     =  0:45:359; %motion directions in degrees
% p.trial.stimulus.nThetas     =  8; %not specifying defaults to all

p.trial.stimulus.dotLifetime   = 100*20/120; % lifetime in seconds
p.trial.stimulus.aperture  = 15; % diameter of the aperture in degrees

p.trial.stimulus.dotDensity    = 2;             %density in dots per square degree
p.trial.stimulus.dotColor1 = [0.15 0.15 0.15]'; %color for half the dots
p.trial.stimulus.dotColor2 = [1 1 1]';          %coilor for the other half          
p.trial.stimulus.apertureType=2; %0: no aperture, 1: square aperture, 2: circle aperture

%%parameters set in conditions (see below)
% p.trial.stimulus.dotSpeed  = 0; % speed in degrees per second
% p.trial.stimulus.coherence = 1; % percent coherence  


%% trial duration information
%atm this still has to be specified. It's e.g. to determine how much data to
%allocate in the pldapsDefaultTrialFunction 
p.trial.pldaps.maxTrialLength = 20; %in seconds
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate; % in frames

%% some switches
p.trial.stimulus.showFixationPoint=true; %do you want a fixation point
p.trial.stimulus.followMouseAtTrialOnset = false; %stimulus center is at mouse position at trial onset throughout trial
p.trial.stimulus.followMouse = true; %stimulus center moves with mouse throughout trial
p.trial.stimulus.fixationFollowsMouseAtTrialOnset = false; %fixation point is at mouse position at trial onset throughout trial
p.trial.stimulus.fixationFollowsMouse = false; % fixation point moved with mouse
p.trial.stimulus.frameratedraw=false; % draw a trace of past frame durations

%%some changes to the deafult settings of pldaps
p.trial.pldaps.draw.cursor.use = true; %show the mouse position? (in experimentor view only)
p.trial.mouse.use=true; % I usually don't capture mouse, unless I use it

% dot sizes in pixels
p.trial.stimulus.eyeW = 10; 
p.trial.stimulus.cursorW = 6; 
p.trial.stimulus.fixdotW = 10;
p.trial.stimulus.dotsW  = 4; 


%% conditions
%create some conditions. not pretty yet

%  cc.dotLifetime = [1000, 0.5];
 cc.dotSpeed = [0 15 30];
 cc.coherence = [0.25 0.5 1];
 
 
 fn=fieldnames(cc);
 numConds=1;
 for parameter=1:length(fn)
     numConds=numConds*length(cc.(fn{parameter}));
 end
 
 c=cell(1,numConds);
 numCondsTillNow=1;
 for parameter=1:length(fn)
     numParmValues=length(cc.(fn{parameter}));
     
     for condition=1:numConds
         thisParmValue=floor(mod((condition-1)/numCondsTillNow,numParmValues)+1);
         if(isnumeric(cc.(fn{parameter})) || islogical(cc.(fn{parameter})))
             c{condition}.(fn{parameter})=cc.(fn{parameter})(thisParmValue);
         else
             fn2=fieldnames(cc.(fn{parameter}){thisParmValue});
             for ParmValueField=1:length(fn2)
                c{condition}.(fn2{ParmValueField})=cc.(fn{parameter}){thisParmValue}.(fn2{ParmValueField});
             end            
         end
         
     end
     
     numCondsTillNow=numCondsTillNow*numParmValues;
 end
 

  
 for condition=1:numConds
     ctmp.stimulus=c{condition};
     ctmp.nr = condition;
     c{condition}=ctmp;
 end
 
 c=repmat(c,1,200);
  
 p.conditions=Shuffle(c); %rand , can't specifiy the rng here, but we set the default so it's ok.

 %maximum number of trials, defaults to inf
 p.trial.pldaps.finish = 1e3; 

 % setup default trial values in the p.trial struct
 p = defaultTrialVariables(p);

