function xN=deg2pixNL(p,xdeg,mstring,screenProfile)
%transform degrees into pixel
%mstring specifies whether pixels should be computed using round, ceil, or
%no rounding
%screenProfile switches to flat screens, otherwise we assume that the screen is
%curved.

%we assume here that pixels are square

pixpercmX = p.trial.display.w2px(1);


%stimulus width in cm
if screenProfile==1 %curved
    xcm = 2*pi*p.trial.display.viewdist*xdeg/360;  
else %flat
    xcm = 2*p.trial.display.viewdist*tan(xdeg/2*pi/180);  
end

%stimulus width in pixels
if strcmp(mstring,'round')
    xN = round(xcm*pixpercmX);  
elseif strcmp(mstring,'ceil')
    xN = ceil(xcm*pixpercmX);
else
    xN = xcm*pixpercmX;
end

