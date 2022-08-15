classdef FindPeakAlgo3_3 < FindPeakAlgo
    methods
        function obj = FindPeakAlgo3_3()
            obj.name = '3_3';
            obj.interval_ecg = 0.4;
            obj.min_peak = 0.65;
        end
    end
end