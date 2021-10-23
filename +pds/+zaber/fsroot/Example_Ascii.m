% An example of how to communicate with Zaber devices using the Zaber ASCII Protocol
import zaber.motion.ascii.*;
import zaber.motion.*;

try
     % open a serial port
    conn = Connection.openSerialPort('COM2');

    devices = conn.detectDevices();
    device = devices(1);

     % home all axes of device
    device.getAllAxes().home();

    axis = device.getAxis(1);

    % Move axis 1 to 1cm
    axis.moveAbsolute(1, Units.LENGTH_CENTIMETRES);

    % Move axis 1 by additional 5mm
    axis.moveRelative(5, Units.LENGTH_MILLIMETRES);

    % Move axis 1 at 1mm/s for two seconds
    axis.moveVelocity(1, Units.VELOCITY_MILLIMETRES_PER_SECOND);

    pause(2);

    % Stop axis 1 and print its position
    axis.stop();

    position = axis.getPosition(Units.LENGTH_MILLIMETRES);
    fprintf('Position: %d\n', position);

catch exception
    disp(getReport(exception));
end

try
    conn.close();
catch
end
