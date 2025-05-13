function p=triggercam(p,value)

%set trigger that starts actual movie acquisition

if p.trial.camera.use %just to double check
   
    port=p.trial.camera.trigger.channel;
    
    wordvec=zeros(1,24);
    wordvec(port)=value; %it is ok only to update the channels we want to move - the other ones are masked out
    word=bi2de(wordvec);
    
    maskvec=zeros(1,24);
    maskvec(port)=1;
    mask=bi2de(maskvec);

    %set digital channels
    Datapixx('SetDoutValues', word,mask);
    Datapixx('RegWrRd');
end
