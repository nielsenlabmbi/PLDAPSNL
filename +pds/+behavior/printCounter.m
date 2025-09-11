function printCounter(counterVal,counterNames)

%make sure counterNames has the correct orientation
if size(counterNames,1)==1
    counterNames=counterNames';
end

disp(string(counterNames)')
disp(counterVal)