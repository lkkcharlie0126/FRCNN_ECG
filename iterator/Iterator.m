classdef Iterator
    properties
        list
        idx
    end
    methods
        function obj = first(obj)
            obj.idx = 1;
        end
        function obj = next(obj)
            obj.idx = obj.idx + 1;
        end
        function finished = isDone(obj)
            finished = obj.idx > length(obj.list);
        end
        function item = currentItem(obj)
            item = obj.list(obj.idx);
        end
        function index = currentIndex(obj)
            index = obj.idx;
        end
    end
end