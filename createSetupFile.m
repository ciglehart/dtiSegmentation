function createSetupFile()

s.runDirs = [1:7,10:17,19:21];
s.tau = 0.3;
s.useQball = 0;
s.alpha = 0.5;
s.nIterations = 5000;
s.nNuclei = 7;
s.normType = {'L2'};
s.createSeedCentroids = 1;
s.gamma = 100;
dt = date;
setupName = [dt,'_setup.mat'];

if ispc
    setupDir = 'C:\Users\z1102497\Desktop\Main\Misc\dwiSegmentation\setupFiles';
    s.dataPathBase = 'C:\Users\z1102497\Desktop\Main\Misc\dwiSegmentation\case';
else
    setupDir = '/Users/charlesiglehart/Documents/School/Research/data/Monti/setupFiles';
    s.dataPathBase = '/Users/charlesiglehart/Documents/School/Research/data/Monti/case';
end

setupFile = fullfile(setupDir,setupName);
s.setupFile = setupFile; %#ok<STRNU>

save(setupFile,'s');

end