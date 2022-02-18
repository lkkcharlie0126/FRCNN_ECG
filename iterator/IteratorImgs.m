classdef IteratorImgs < Iterator
    methods
        function item = currentItem(obj)
            item = obj.list(obj.idx);
            item = item{1};
        end
    end
end