function LEDOn(p)
%turn the LED on; channel and voltage are specified in p
%this is a wrapper that basically just provides the correct settings for
%analogOut


if p.trial.led.use==1
    pds.datapixx.analogOut(p.trial.led.dacAmp, p.trial.led.channel, p.trial.datapixx.dac.sampleRate);
end



