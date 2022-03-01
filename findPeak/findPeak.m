slash = '\';
subjectsPath = 'D:\Win\WTMH\PAG_group\mitbih_5class\data\10sec\mat';

subjectsList = {dir(fullfile(subjectsPath)).name}';
subjectsList = subjectList(3:end);

for i = 1:length(subjectsList)
    matsPath = [subjectsPath, slash, subjectsList{i}];
    matsList = {dir(fullfile(matsPath, '*.mat')).name}';
    for j = 1:length(matsList)
        signalPath = [matsPath, slash, matsList{j}];
        signal = load(signalPath).signal_10s;
        signal = (signal - min(signal))/max(signal-min(signal));
        
        
        s_rate = 360;
        interval_ecg = 0.3 * s_rate;
        min_peak = 0.7;
        t = (1:length(signal))/s_rate; % Time

        [Ramp,Rpeak,w,p]  = findpeaks(signal,'MinPeakDistance',interval_ecg, 'MinPeakHeight', min_peak);
        
        f1 = figure(1),
        plot(t, signal); hold on;
        plot(Rpeak/s_rate, Ramp, '*');
        close(f1)
    end
end


