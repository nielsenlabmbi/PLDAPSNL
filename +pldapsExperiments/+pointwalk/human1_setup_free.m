function p = human1_setup_free(p)
%experiment setup file for a simple test experiment

%%THIS IS THE GLOBAL OVERALL SET UP

% trying to lock this

%% basic definitions
p = pdsDefaultTrialStructureNL(p); 

%% set the trial function: the function that gets called for each frame state
p.trial.pldaps.trialFunction='pldapsExperiments.pointwalk.human1_trial_free';
%THIS IS NEW EACH TRIAL

%% set general parameters
p.trial.stimulus.forceCorrect = 1;

%% set timing parameters
p.trial.stimulus.duration.ITI = 1;

%% conditions:
%conditions is saved under p as p.conditions
%p.conditions is a 1x500 cell that was created
%each struct of position contains dot coherence, direction and side
side.par = 'direction';
side.match=p.defaultParameters.stimulus.direction; 

%remeber in the earlier version, p.phase_coherence doesnt exist, it is speed

if iscell(p.defaultParameters.stimulus.phase_coherence)
    for i = 1:length(p.defaultParameters.stimulus.phase_coherence)
        cond(i).phase_coherence = p.defaultParameters.stimulus.phase_coherence{i};
        cond(i).direction = p.defaultParameters.stimulus.direction;
        cond(i).movieId=p.defaultParameters.stimulus.movieId;
        if length(cond(i).phase_coherence) > 2
            c{i}=generateCondList_sides(cond(i),side,'pseudo',ceil(500/(length(cond(i).phase_coherence)*2)));
        else
            c{i}=generateCondList(cond(i),side,'pseudo',ceil(500/(length(cond(i).phase_coherence)*2)));
        end
    end
    p.trial.allconditions = c;
    p.trialMem.whichConditions = 0;
    p.conditions=p.trial.allconditions{p.trialMem.whichConditions + 1};
    
    p.trial.pldaps.finish = length(p.conditions);
    
else
    cond.phase_coherence = p.defaultParameters.stimulus.phase_coherence;
    cond.direction = p.defaultParameters.stimulus.direction;%[0 180];
    cond.movieId=p.defaultParameters.stimulus.movieId;
    %cond.speed=p.defaultParameters.stimulus.speed;%[0 in place 1 fast 2 slow]
    if length(cond.phase_coherence) > 2
       c=generateCondList_sides(cond,side,'pseudo',ceil(500/(length(cond.phase_coherence)*2)));
    else
        c=generateCondList(cond,side,'pseudo',ceil(500/(length(cond.movieId)*2)));
    end
    %there might be a big flag here
    p.conditions=c;
    
    p.trial.pldaps.finish = length(p.conditions);
end

    


%% display stats
p.trialMem.stats.cond={'direction', 'phase_coherence'}; %conditions to display %took out movie id and replaced speed with distance for now
if length(cond)>1
    [A,B] = ndgrid(cond(end).direction,cond(end).phase_coherence); %replaced movid and took out speed
else
[A,B] = ndgrid(cond.direction, cond.phase_coherence); %changed dotcoherence to movieId after reference to non existent field error
end
p.trialMem.stats.val = [A(:),B(:)]';
nCond=size(p.trialMem.stats.val,2);
p.trialMem.stats.count.correct=zeros(1,nCond);
p.trialMem.stats.count.incorrect=zeros(1,nCond);
p.trialMem.stats.count.Ntrial=zeros(1,nCond);