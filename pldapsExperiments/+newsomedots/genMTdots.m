function dotsXY = genMTdots(dotparams, frames, frate, rgen)

%% parameters
thetas  = dotparams.thetas; 
nthetas = length(thetas); 
%we are potentially creating more frames than requested
%i.e. last pulse will be shown up to nthetas-1 frames less than the rest
frames=ceil(frames/nthetas);

density = dotparams.dotDensity; 
apert   = dotparams.aperture;

lifetime    = round(dotparams.dotLifetime*frate); % frame lifetime
coh         = dotparams.coherence; % trial coherence
speed       = dotparams.dotSpeed/frate; % trial speed

ndots       = round(density*apert^2); 

%% start location and other randomized parameters
dots = rand(rgen,ndots,2)*apert; 
nd = rand(rgen,ndots,frames*nthetas) > coh;
newd= rand(rgen,ndots,2,frames*nthetas)*apert; 

%% allocate data
dotsXY = zeros(2,ndots,frames*nthetas);

for th = 1:nthetas
    
    dlife = randi(rgen,lifetime, ndots, 1); 
    
    theta   = thetas(th);
    dx      = cosd(theta)*speed; 
    dy      = sind(theta)*speed; 
    
    
    if th > 1
        b = frames*(th-1);
    else
        b = 0;
    end
       
    for fr = 1:frames
        noisedots=nd(:,b + fr);
        sigdots = ~noisedots;
        dlife(noisedots) = 0;
        killthese = dlife > lifetime;
        dlife(killthese) = 0;
        noise = noisedots | killthese;
        dots(noise, :) = newd(1:sum(noise),:,b + fr);
        
        dots(sigdots, 2) = dots(sigdots,2) + dy;
        dots(sigdots, 1) = dots(sigdots,1) + dx;
        
        dots = mod(dots, apert);
        
        impixels = dots-apert/2;
        
        dotsXY(:,:,b + fr) = impixels';
        
        dlife = dlife + 1;
    end

end




