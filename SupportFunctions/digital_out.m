function digital_out(channel,digword)

    wordvec=zeros(1,24);
    wordvec(channel)=digword; 
    word=bi2de(wordvec);
    
    maskvec=zeros(1,24);
    maskvec(channel)=1;
    mask=bi2de(maskvec);

    %set digital channels
    Datapixx('SetDoutValues', word,mask);
    Datapixx('RegWrRd');
    