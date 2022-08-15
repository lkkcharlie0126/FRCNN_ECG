classdef FindPeakAlgo3 < FindPeakAlgo
    methods
        function obj = FindPeakAlgo3()
            obj.name = '3';
            obj.interval_ecg = 0.4;
            obj.min_peak = 0.6;
        end
    end
end