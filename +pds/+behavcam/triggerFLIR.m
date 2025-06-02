function p=triggerFLIR(p,value)

%send a trigger pulse to FLIR that alerts camera to when animal has crossed
%start port IR beam. Set trigger then, trigger off

if p.trial.camera.use %just to double check
   
    port=p.trial.camera.trigger.channel;
 
    wordvec=zeros(1,24);
    wordvec(port)=value; %it is ok only to update the channels we want to move - the other ones are masked out
    word=bi2de(wordvec);
    
    maskvec=zeros(1,24);
    maskvec(port)=1;
    mask=bi2de(maskvec);

    %set digital channels on
    Datapixx('SetDoutValues', word,mask);
    Datapixx('RegWrRd');

    %doing this hiccup step because I do not want constant triggering

    %set digital channels off
    Datapixx('SetDoutValues', 0)
    Datapixx('RegWrRd')
end
