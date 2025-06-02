function stimLEDOn(p)
%turn the LED on; channel and voltage are specified in p
%this is a wrapper that basically just provides the correct settings for
%analogOut


if p.trial.led.use==1
    %pds.datapixx.analogOut(p.trial.led.dacAmp, p.trial.led.channel, p.trial.datapixx.dac.sampleRate);
    wordvec=zeros(1,24);
    wordvec(p.trial.led.channel2)=1; %it is ok only to update the channels we want to move - the other ones are masked out
    word=bi2de(wordvec);
    
    maskvec=zeros(1,24);
    maskvec(p.trial.led.channel2)=1;
    mask=bi2de(maskvec);
    
    
    Datapixx('SetDoutValues', word,mask);
    Datapixx('RegWrRd');
end



