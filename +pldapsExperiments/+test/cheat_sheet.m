%% Cheat sheet for Chiad (training FBAA4 and FBAA0)

%% FBAA4: press 'run section', or copy and paste into command window
settingsStruct = pldapsExperiments.gambling.gambling_FBAA4Settings;
p = pldaps(@pldapsExperiments.gambling.gambling0_setup,'FBAA4',settingsStruct);
p.run

%% FBAA0: press 'run section', or copy and paste into command window
settingsStruct = pldapsExperiments.gambling.gambling_FBAA0Settings;
p = pldaps(@pldapsExperiments.gambling.gambling0_setup,'FBAA0',settingsStruct);
p.run

%% FBAA5: press 'run section', or copy and paste into command window
settingsStruct = pldapsExperiments.gambling.gambling_FBAA5Settings;
p = pldaps(@pldapsExperiments.gambling.gambling0_setup,'FBAA5',settingsStruct);
p.run

%% FBAA6: press 'run section', or copy and paste into command window
settingsStruct = pldapsExperiments.dots.dots_FBAA6Settings_free;
p = pldaps(@pldapsExperiments.dots.dots_setup_free,'FBAA6',settingsStruct);
p.run
