classdef FindPeakAlgo4 < FindPeakAlgo
    methods
        function obj = FindPeakAlgo4()
            obj.name = '4';
            obj.interval_ecg = 0.4;
        end
        function [Ramp, Rpeak, signal] = findPeak(obj, signal, s_rate)
            signal = (signal - min(signal))/max(signal-min(signal));
        
            min_interval = obj.interval_ecg * s_rate;
            obj.min_peak = quantile(signal, 0.96);
%             t = (1:length(signal))/s_rate; % Time
            [Ramp,Rpeak,~,~]  = findpeaks(signal,'MinPeakDistance',...
                min_interval, 'MinPeakHeight', obj.min_peak);
            
%             f1 = figure(1);
%             plot(t, signal); hold on;
%             plot(Rpeak/s_rate, Ramp, '*');
%             close(f1)
        end
    end
end