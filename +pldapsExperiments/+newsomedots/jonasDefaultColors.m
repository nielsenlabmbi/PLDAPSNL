function p = jonasDefaultColors(p)
%some meaningfull understandable colors for this annoying color scheme
%system
%     p.defaultParameters.display.humanCLUT(12,:)=[1 0 0];
%     p.defaultParameters.display.monkeyCLUT(12,:)=[0 1 0];
% 
%     p.defaultParameters.display.humanCLUT(13,:)=[0 1 0];
%     p.defaultParameters.display.monkeyCLUT(13,:)=p.defaultParameters.display.bgColor;
    if p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay
        p.defaultParameters.display.clut.hGreen=12*[1 1 1]';
    else
        p.defaultParameters.display.clut.hGreen=p.defaultParameters.display.humanCLUT(12+1,:)';
    end
% 
%     p.defaultParameters.display.humanCLUT(14,:)=[1 0 0];
%     p.defaultParameters.display.monkeyCLUT(14,:)=p.defaultParameters.display.bgColor;
    if p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay
        p.defaultParameters.display.clut.hRed=13*[1 1 1]';
    else
        p.defaultParameters.display.clut.hRed=p.defaultParameters.display.humanCLUT(13+1,:)';
    end
% 
%     p.defaultParameters.display.humanCLUT(15,:)=[0 0 0];
%     p.defaultParameters.display.monkeyCLUT(15,:)=p.defaultParameters.display.bgColor;
    if p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay
        p.defaultParameters.display.clut.hBlack=14*[1 1 1]';
    else
        p.defaultParameters.display.clut.hBlack=p.defaultParameters.display.humanCLUT(14+1,:)';
    end

    p.defaultParameters.display.humanCLUT(16,:)=[1 0 0];
    p.defaultParameters.display.monkeyCLUT(16,:)=[1 0 0];
    if p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay
        p.defaultParameters.display.clut.bRed=15*[1 1 1]';
    else
        p.defaultParameters.display.clut.bRed=p.defaultParameters.display.humanCLUT(15+1,:)';
    end

    p.defaultParameters.display.humanCLUT(17,:)=[0 1 0];
    p.defaultParameters.display.monkeyCLUT(17,:)=[0 1 0];
    if p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay
        p.defaultParameters.display.clut.bGreen=16*[1 1 1]';
    else
        p.defaultParameters.display.clut.bGreen=p.defaultParameters.display.humanCLUT(16+1,:)';
    end

    p.defaultParameters.display.humanCLUT(18,:)=[1 1 1];
    p.defaultParameters.display.monkeyCLUT(18,:)=[1 1 1];
    if p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay
        p.defaultParameters.display.clut.bWhite=17*[1 1 1]';
    else
        p.defaultParameters.display.clut.bWhite=p.defaultParameters.display.humanCLUT(17+1,:)';
    end

    p.defaultParameters.display.humanCLUT(19,:)=[0 0 0];
    p.defaultParameters.display.monkeyCLUT(19,:)=[0 0 0];
    if p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay
        p.defaultParameters.display.clut.bBlack=18*[1 1 1]';
    else
        p.defaultParameters.display.clut.bBlack=p.defaultParameters.display.humanCLUT(18+1,:)';
    end

    p.defaultParameters.display.humanCLUT(20,:)=[0 0 1];
    p.defaultParameters.display.monkeyCLUT(20,:)=[0 0 1];
    if p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay
        p.defaultParameters.display.clut.bBlue=19*[1 1 1]';
    else
        p.defaultParameters.display.clut.bBlue=p.defaultParameters.display.humanCLUT(19+1,:)';
    end

    p.defaultParameters.display.humanCLUT(21,:)=[0 0 1];
    p.defaultParameters.display.monkeyCLUT(21,:)=p.defaultParameters.display.bgColor;
    if p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay
        p.defaultParameters.display.clut.hBlue=20*[1 1 1]';
    else
        p.defaultParameters.display.clut.hBlue=p.defaultParameters.display.humanCLUT(20+1,:)';
    end

