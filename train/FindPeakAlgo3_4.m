classdef FindPeakAlgo3_4 < FindPeakAlgo
    methods
        function obj = FindPeakAlgo3_4()
            obj.name = '3_4';
            obj.interval_ecg = 0.45;
            obj.min_peak = 0.7;
        end
    end
end