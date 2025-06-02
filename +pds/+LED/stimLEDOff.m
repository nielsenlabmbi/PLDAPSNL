function stimLEDOff(p)
%turn the LED off; channel is given p
%this relies on a DIO channel

if p.trial.led.use==1
    %pds.datapixx.analogOut(0, p.trial.led.channel, p.trial.datapixx.dac.sampleRate);
    
    wordvec=zeros(1,24);
    wordvec(p.trial.led.channel2)=0; %it is ok only to update the channels we want to move - the other ones are masked out
    word=bi2de(wordvec);
    
    maskvec=zeros(1,24);
    maskvec(p.trial.led.channel2)=1;
    mask=bi2de(maskvec);
    
    Datapixx('SetDoutValues', word,mask);
    Datapixx('RegWrRd');
end



