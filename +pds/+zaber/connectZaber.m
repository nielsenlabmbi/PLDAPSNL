function connectZaber(p)

global zaber 
%we can't use p to hold the zaber connections because they tie into their library
%and the params structure conflicts with calling those commands

if p.trial.zaber.use
    import zaber.motion.Library;
    import zaber.motion.ascii.Connection;
    import zaber.motion.ascii.AllAxes;
    import zaber.motion.ascii.Axis;
    
    Library.enableDeviceDbStore();
    
    zaber.connection=Connection.openSerialPort(p.trial.zaber.port);
    
    try
        deviceList = zaber.connection.detectDevices();
        fprintf('Found %d devices.\n', deviceList.length);
        
        for i=1:length(deviceList)
            zaber.device(i)=deviceList(i);
            zaber.axis(i)=zaber.device(i).getAxis(1);
        end
        
    catch exception
        zaber.connection.close();
        fprintf('Error connection to Zaber stages\n');
        rethrow(exception);
    end
end

