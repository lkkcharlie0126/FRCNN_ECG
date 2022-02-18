classdef ImageResizer
    properties
        slash = '\';
        path_parent = fileparts(fileparts(cd));
        folderOriginal
        folderNew
        pathOriginalImg
        pathNewImg
        subject_list
        img_list
        img
        imgResize
        wantedSize
        pathEachSubject
        pathEachSubjectSave
        pathEachImg
        pathEachImgSave
    end
    methods
        function obj = setPath(obj)
            obj.pathOriginalImg = [obj.path_parent, obj.slash, 'data', obj.slash, obj.folderOriginal];
            obj.pathNewImg = [obj.path_parent, obj.slash, 'data', obj.slash,  obj.folderNew];

            obj.subject_list = {dir(fullfile(obj.pathOriginalImg)).name}';
            obj.subject_list = obj.subject_list(3:end);
        end

        function obj = iterateEachSubject(obj)
            iteratorSubject = IteratorSubjects;
            iteratorSubject.list = obj.subject_list;
            iteratorSubject = iteratorSubject.first();
            while(~iteratorSubject.isDone())
                subject = iteratorSubject.currentItem();
                obj.pathEachSubject = [obj.pathOriginalImg, obj.slash, subject];
                obj.pathEachSubjectSave = [obj.pathNewImg, obj.slash, subject];
                mkdir(obj.pathEachSubjectSave);
                obj.img_list = {dir(fullfile(obj.pathEachSubject, '*.png')).name}';
                obj = obj.iterateEachImg();

                iteratorSubject = iteratorSubject.next();
            end
        end

        function obj = iterateEachImg(obj)
            iteratorImg = IteratorImgs;
            iteratorImg.list = obj.img_list;
            iteratorImg = iteratorImg.first();
            while(~iteratorImg.isDone())
                nameEachImg = iteratorImg.currentItem();
                obj.pathEachImg = [obj.pathEachSubject, obj.slash, nameEachImg];
                obj.pathEachImgSave = [obj.pathEachSubjectSave, obj.slash, nameEachImg];

                obj.resize();

                iteratorImg = iteratorImg.next();
            end
        end

        function resize(obj)
            obj.img = imread(obj.pathEachImg);
            obj.imgResize = imresize(obj.img, obj.wantedSize);
            imwrite(obj.imgResize, obj.pathEachImgSave);
        end
    end
end