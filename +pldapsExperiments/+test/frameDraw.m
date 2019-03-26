function frameDraw(s)
%this holds the code to draw some stuff to the overlay (using
%switches, like the grid, the eye Position, etc

%consider moving this stuff to an earlier timepoint, to allow GPU
%to crunch on this before the real stuff gets added.

%did the background color change? Usually already applied after
%frameFlip, but make sure we're not missing anything
if any(s.pldaps.lastBgColor~=s.display.bgColor)
    Screen('FillRect', s.display.ptr,s.display.bgColor);
    s.pldaps.lastBgColor = s.display.bgColor;
end


% %draw a history of fast inter frame intervals
% if s.pldaps.draw.framerate.use && s.iFrame>2
%     %update data
%     s.pldaps.draw.framerate.data=circshift(s.pldaps.draw.framerate.data,-1);
%     s.pldaps.draw.framerate.data(end)=s.timing.flipTimes(1,s.iFrame-1)-s.timing.flipTimes(1,s.iFrame-2);
%     %plot
%     if s.pldaps.draw.framerate.show
%         %adjust y limit
%         s.pldaps.draw.framerate.sf.ylims=[0 max(max(s.pldaps.draw.framerate.data), 2*s.display.ifi)];
%         %current ifi is solid black
%         pds.pldaps.draw.screenPlot(s.pldaps.draw.framerate.sf, s.pldaps.draw.framerate.sf.xlims, [s.display.ifi s.display.ifi], s.display.clut.blackbg, '-');
%         %2 ifi reference is 5 black dots
%         pds.pldaps.draw.screenPlot(s.pldaps.draw.framerate.sf, s.pldaps.draw.framerate.sf.xlims(2)*(0:0.25:1), ones(1,5)*2*s.display.ifi, s.display.clut.blackbg, '.');
%         %0 ifi reference is 5 black dots
%         pds.pldaps.draw.screenPlot(s.pldaps.draw.framerate.sf, s.pldaps.draw.framerate.sf.xlims(2)*(0:0.25:1), zeros(1,5), s.display.clut.blackbg, '.');
%         %data are red dots
%         pds.pldaps.draw.screenPlot(s.pldaps.draw.framerate.sf, 1:s.pldaps.draw.framerate.nFrames, s.pldaps.draw.framerate.data', s.display.clut.blackbg, '.');
%     end
% end

%draw the eyepositon to the second srceen only
%move the color and size parameters to
if s.pldaps.draw.eyepos.use && s.iFrame>2
    if s.pldaps.draw.eyepos.lastacq == 1;
        s.pldaps.draw.eyepos.baseline1 = mean(s.datapixx.adc.eyepos(1,1:5));
        s.pldaps.draw.eyepos.baseline2 = mean(s.datapixx.adc.eyepos(2,1:5));
        %adjust Y limit
        s.pldaps.draw.eyepos.sf.ylims = s.pldaps.draw.eyepos.sf.ylims + s.pldaps.draw.eyepos.baseline1;
        s.pldaps.draw.eyepos.sf2.ylims = s.pldaps.draw.eyepos.sf2.ylims + s.pldaps.draw.eyepos.baseline2;
    end
    %update data
    s.pldaps.draw.eyepos.acq = s.datapixx.adc.dataSampleCount;
    s.pldaps.draw.eyepos.dataX=circshift(s.pldaps.draw.eyepos.dataX,-1);
    s.pldaps.draw.eyepos.dataX(end) = mean(s.datapixx.adc.eyepos(1,s.pldaps.draw.eyepos.lastacq:s.pldaps.draw.eyepos.acq));
    s.pldaps.draw.eyepos.dataY=circshift(s.pldaps.draw.eyepos.dataY,-1);
    s.pldaps.draw.eyepos.dataY(end) = mean(s.datapixx.adc.eyepos(2,s.pldaps.draw.eyepos.lastacq:s.pldaps.draw.eyepos.acq));
    s.pldaps.draw.eyepos.lastacq = s.pldaps.draw.eyepos.acq;
    if s.pldaps.draw.eyepos.show
%         %current ifi is solid black
%         pds.pldaps.draw.screenPlot(s.pldaps.draw.framerate.sf, s.pldaps.draw.framerate.sf.xlims, [s.display.ifi s.display.ifi], s.display.clut.blackbg, '-');
%         %2 ifi reference is 5 black dots
%         pds.pldaps.draw.screenPlot(s.pldaps.draw.framerate.sf, s.pldaps.draw.framerate.sf.xlims(2)*(0:0.25:1), ones(1,5)*2*s.display.ifi, s.display.clut.blackbg, '.');
%         %0 ifi reference is 5 black dots
%         pds.pldaps.draw.screenPlot(s.pldaps.draw.framerate.sf, s.pldaps.draw.framerate.sf.xlims(2)*(0:0.25:1), zeros(1,5), s.display.clut.blackbg, '.');
        %data are red dots
        pds.pldaps.draw.screenPlot(s.pldaps.draw.eyepos.sf, 1:s.pldaps.draw.eyepos.nFrames, s.pldaps.draw.eyepos.dataX', s.display.clut.redbg, '.');
        pds.pldaps.draw.screenPlot(s.pldaps.draw.eyepos.sf2, 1:s.pldaps.draw.eyepos.nFrames, s.pldaps.draw.eyepos.dataY', s.display.clut.greenbg, '.');    
    end

    %Screen('Drawdots',  s.display.overlayptr, [s.eyeX s.eyeY]', ...
     %   s.stimulus.eyeW, s.display.clut.eyepos, [0 0],0);
end
if s.mouse.use && s.pldaps.draw.cursor.use
    Screen('Drawdots',  s.display.overlayptr,  s.mouse.cursorSamples(1:2,s.mouse.samples), ...
        s.stimulus.eyeW, s.display.clut.cursor, [0 0],0);
end

%draw squares to indicate response port status and position
if s.ports.use && s.pldaps.draw.ports.show
    pds.ports.drawPorts(s.display.overlayptr,s.pldaps.draw.ports.statusDisp,...
        s.ports.status,s.display.clut.blackbg,s.display.clut.redbg);
    
    if s.ports.movable
        pds.ports.drawPorts(s.display.overlayptr,s.pldaps.draw.ports.positionDisp,...
            s.ports.position,s.display.clut.blackbg,s.display.clut.redbg);
    end
end

end %frameDraw
