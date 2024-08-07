clearvars
close all
clc

parameters.testCase = 1;
parameters.numStrips = 13;
parameters.saveInfo = true;

run('../run.m')

clearvars

parameters.testCase = 2;
parameters.numStrips = 13;
parameters.saveInfo = true;

run('../run.m')

clearvars

parameters.testCase = 3;
parameters.numStrips = 13;
parameters.saveInfo = true;

run('../run.m')

clearvars
close all
clc

maxStrips = 18;
maxCases = 3;

timers = zeros(maxStrips-1,2,maxCases);
for testCase = 1:maxCases
    for numStrips = 2:maxStrips
        parameters.testCase = testCase;
        parameters.numStrips = numStrips;
        parameters.saveInfo = false;
        run('../run.m')
        timers(numStrips-1,:,testCase) = [timerFVM,timerDM];
        clear 'Lx' 'Ly' 'grid' 'parameters'
    end
end

save('timerInfo.mat','timers')
