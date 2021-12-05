%% This version actually works

ind = find(noisevec(:, 1) == 1);

if p.trial.stimulus.direction==180   
    idea = find(randdotvec(ind, 1) >= 1000);
    for herewego = 1:length(idea)
        randdotvec(ind(idea(herewego)), 1) = -920 + (920 - (-920)).*rand(1, 1);
    end
    idea = find(randdotvec(ind, 1) <= -1000);
    for herewego = 1:length(idea)
        randdotvec(ind(idea(herewego)), 1) = -920 + (920 - (-920)).*rand(1, 1);
    end
    randdotvec(ind, 1) = randdotvec(ind, 1) + (1980 /(size(coordvec,3)));

elseif p.trial.stimulus.direction==0   
    idea = find(randdotvec(ind, 1) >= 1000);
    for herewego = 1:length(idea)
        randdotvec(ind(idea(herewego)), 1) = -920 + (920 - (-920)).*rand(1, 1);
    end
    idea = find(randdotvec(ind, 1) <= -1000);
    for herewego = 1:length(idea)
        randdotvec(ind(idea(herewego)), 1) = -920 + (920 - (-920)).*rand(1, 1);
    end
    randdotvec(ind, 1) = randdotvec(ind, 1) - (1980 /(size(coordvec,3)));
end
    
%% this version does NOT

    
    
    

%I WANT TO KEEP THIS PORTION BELOW, THIS IS THE BEST WORKING ONE SO FAR
    
%     if p.trial.stimulus.direction==180 
%         
%         randdotvec(randdotvec(ind, 1) >= 1000) = -920 + (920 - (-920)).*rand(length(randdotvec(randdotvec(ind, 1) >= 1000)), 1);
%         randdotvec(randdotvec(ind, 1) <= -1000) = -920 + (920 - (-920)).*rand(length(randdotvec(randdotvec(ind, 1) <= -1000)), 1);
%         randdotvec(ind, 1) = randdotvec(ind, 1) + (1980 /(size(coordvec,3)));
%     elseif p.trial.stimulus.direction==0
%         
%         randdotvec(randdotvec(ind, 1) >= 1000) = -920 + (920 - (-920)).*rand(length(randdotvec(randdotvec(ind, 1) >= 1000)), 1);
%         randdotvec(randdotvec(ind, 1) <= -1000) = -920 + (920 - (-920)).*rand(length(randdotvec(randdotvec(ind, 1) <= -1000)), 1);
%         randdotvec(ind, 1) = randdotvec(ind, 1) - (1980 /(size(coordvec,3)));
%     end


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    idea = find(randdotvec(ind, 1) >= 1000);
    for herewego = 1:length(idea)
        randdotvec(ind(idea(herewego)), 1) = -920 + (920 - (-920)).*rand(1, 1);
    end
    idea = find(randdotvec(ind, 1) <= -1000);
    for herewego = 1:length(idea)
        randdotvec(ind(idea(herewego)), 1) = -920 + (920 - (-920)).*rand(1, 1);
    end
%% 

        