% An example of how to communicate with Zaber devices using the Zaber Binary Protocol
import zaber.motion.binary.*;
import zaber.motion.*;

try
     % open a serial port
    conn = Connection.openSerialPort('COM2');

    devices = conn.detectDevices();
    device = devices(1);

    fprintf('Device %d has device ID %d.\n', device.getDeviceAddress(), device.getIdentity().getDeviceId());

    % home device
    pos = device.home(Units.LENGTH_CENTIMETRES);
    fprintf('Position after home: %.2f cm.\n', pos);

    % move device to 1cm
    pos = device.moveAbsolute(1.0, Units.LENGTH_CENTIMETRES);
    fprintf('Position after move absolute: %.2f cm.\n', pos);

    % Move axis 1 by additional 5mm
    pos = device.moveRelative(5.0, Units.LENGTH_MILLIMETRES);
    fprintf('Position after move relative: %.2f mm.\n', pos);

    % Move device at 1mm/second for 2 seconds
    velocity = device.moveVelocity(1.0, Units.VELOCITY_MILLIMETRES_PER_SECOND);
    fprintf('Starting move velocity with speed: %.2f mm/s.\n', velocity);

    pause(2);

    % Stop device
    pos = device.stop(Units.LENGTH_CENTIMETRES);
    fprintf('Position after stop: %.2f cm.\n', pos);

    % print the final position of device
    fprintf('Final position in microsteps: %.2f.\n', device.getPosition());

catch exception
    disp(getReport(exception));
end

try
    conn.close();
catch
end
