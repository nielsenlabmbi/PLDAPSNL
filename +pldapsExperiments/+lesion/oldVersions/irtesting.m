function irtesting()
    % Initialize
    Datapixx('Open');
    inputChannel = 8;  % Change to your input channel
    updateInterval = 0.2; % Update every 0.2 seconds
    
    fprintf('Monitoring Digital Input Channel %d\n', inputChannel);
    fprintf('Press Ctrl-C to quit\n\n');
    
    try
        while true
            % Read current state
            Datapixx('RegWrRd');
            currentState = bitget(Datapixx('GetDinValues'), inputChannel + 1);
            
            % Display status
            if currentState
                fprintf('%.1f s: Beam CLEAR (High)\n', GetSecs);
            else
                fprintf('%.1f s: Beam BROKEN (Low)\n', GetSecs);
            end
            
            % Wait for next update
            WaitSecs(updateInterval);
        end
        
    catch
        % This will catch Ctrl-C interruption
        fprintf('\nMonitoring stopped by user\n');
    end
    
    % Cleanup
    Datapixx('Close');
end