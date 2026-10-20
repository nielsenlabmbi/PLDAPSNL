function s = ori_stereo_BWdots_FBAD7Settings

%set reward amounts
s.behavior.reward.amount = [0.15 0.35 0.35 0.35];
%set orientation and offsets
s.stimulus.midpointIR = 1; %use midpoint IR beam to turn off stimulus

s.stimulus.offStim=1;

%Added to try vert grating w/offset 6/1/26
s.stimulus.refangle=90; 
s.stimulus.rotation=[-1,1]; %flipped relative to normal grating because matrix indexing flips it otherwise
s.stimulus.displacement=45;

s.stimulus.sf = 0.25;
s.stimulus.dotSize=1; %diameter
s.stimulus.dotSpacing=1.5; %spacing between centers 


s.stimulus.range = 121;
s.stimulus.fullField = 1;


%set viewing parameters
s.stimulus.duration.ITI = 1;

%set up the viewing distance
s.display.viewdist = 75; 

s.stimulus.cond.Ncond=2; %stim offset L/R
s.stimulus.cond.counterIdx{1}=[1 2];
s.stimulus.cond.counterNames{1}={'L offset'; 'R offset';};
