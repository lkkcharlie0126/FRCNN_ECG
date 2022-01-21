%% Last editted: 2021.01.20
%% by Wen Tzu Chien
%%
classdef DataCutter
    properties
        %% Path setting
        folder_parent = fileparts(fileparts(cd));
        folder_AAMI
        folder_save
        folder_saveName = 'test'
        slash = '/'
        %% Parameter setting
        time_window = 10;
        step_window = 10;
        Fs = 360;
        % CWT
        fmin = 0.1;
        fmax = 40;
        fstep = 0.2;
        % Diseases
        diseases = {'SR', 'APC', 'VPC', 'LBBB', 'RBBB', 'Others'};
        
        % Beat width
        set_box_width = [0.7];
        % Two class
        two_class = 0;
        % RGB or Gray
        gray = 0;
        % Add top
        addtop = 0;
        % TWCC
        istwcc = 0;
        % Resize
        isResize = 1;
        % Img size
        wanted_img_size = [227, 681, 3]
        
        type_name = [''];
        num_class
        subject_list
        beat_left
        beat_right
        bboxTable

        subjectName
        raw_data
        label
        sample
        index_10s
        win_start
        win_end
        
        win_SR = [];
        win_APC = [];
        win_VPC = [];
        win_LBBB = [];
        win_RBBB = [];
        win_Others = [];
        win_Peak = [];
        
        py_single = [];
        py_multi = [];
        win_label
        win_sample

        beatNum
    end
    methods
        function obj = DataCutter()
            obj.folder_AAMI = [obj.folder_parent, obj.slash, 'AAMI'];
            obj.num_class = length(obj.diseases);
            obj.subject_list = {dir(fullfile(obj.folder_AAMI,'*.txt')).name}';
        end

        function run(obj)
            obj = obj.setup();
            obj.iterateEachSubject();
        end

        function obj = setup(obj)
            obj.folder_save = [obj.folder_parent, obj.slash, 'data', obj.slash, obj.folder_saveName];
            if obj.two_class
                obj.type_name = [obj.type_name, '_1'];
            end
            if obj.istwcc
                obj.type_name = [obj.type_name, '_twcc'];
            end
            if obj.set_box_width(1) == 0.7
                obj.beat_left = round(0.307*obj.Fs);
                obj.beat_right = round(0.404*obj.Fs);
            else
                obj.beat_left = round(obj.set_box_width(1)/2*obj.Fs);
                obj.beat_right = round(obj.set_box_width(1)/2*obj.Fs);
            end
            obj.folder_save = [obj.folder_parent, obj.slash, 'data', obj.slash, obj.folder_saveName];
        end
        
        function iterateEachSubject(obj)
            iteratorSubject = Iterator;
            iteratorSubject.list = obj.subject_list;
            iteratorSubject = iteratorSubject.first();
            while(~iteratorSubject.isDone())
                subject = iteratorSubject.currentItem();
                subject = subject{1};
                obj = obj.createSaveFoldeer(subject);
                obj = obj.loadData(subject);
                obj.bboxTable = obj.InitBoxTable();
                obj = obj.iterateEachWindow();

                obj.saveBboxTable();
                iteratorSubject = iteratorSubject.next();
            end
        end

        function obj = createSaveFoldeer(obj, subject)
            %% Create save folder
            obj.subjectName = ['s', subject(1:end-5)]; 
            mkdir([obj.folder_save, obj.slash, 'mat', obj.slash, obj.subjectName]);
%             mkdir([obj.folder_save, '\signal_axis\',  obj.subjectName]);
%             mkdir([obj.folder_save, '\signal\',  obj.subjectName]);
            mkdir([obj.folder_save, obj.slash, 'signal_resize', obj.slash, obj.subjectName]);
%             mkdir([obj.folder_save, '\cwt_axis\',  obj.subjectName]);
%             mkdir([obj.folder_save, '\cwt\',  obj.subjectName]);
            mkdir([obj.folder_save, obj.slash, 'box', obj.slash, 'new', obj.slash, 'matlab', obj.slash, char(string(obj.set_box_width(1))), obj.type_name, obj.slash, obj.subjectName]);
%             mkdir([obj.folder_save, '\box\new\python\label_all\single\']);
%             mkdir([obj.folder_save, '\box\new\python\label_all\multi\']);
%             mkdir([obj.folder_save, '\singleBeat\',  obj.subjectName]);
        end
        
        function obj = loadData(obj, subject)
            %% File path
            file_txt = [obj.folder_AAMI, obj.slash, subject];
            file_mat = [file_txt(1:end-3), 'mat'];
            %% Read .txt data
            % For more information, see the TEXTSCAN documentation.
            formatSpec = '%12s%9s%6s%5s%5s%s%[^\n\r]';
            fileID = fopen(file_txt,'r');
            dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string',  'ReturnOnError', false);
            dataArray{1} = strtrim(dataArray{1});
            fclose(fileID);
            %% Clear temporary variables
            clearvars fileID formatSpec ans ;
            %% Load .mat data
            load(file_mat);
            obj.raw_data = val(1,:)';
            %% Sample number and label
            obj.label = char(dataArray{1,3}(2:end));
            obj.label = obj.label(:,end);
            obj.sample = str2num(char(dataArray{1,2}(2:end)));
            %% Time window
            obj.index_10s = 1 : obj.step_window*obj.Fs : length(obj.raw_data);
            while (obj.index_10s(end) + obj.time_window * obj.Fs - 1) > length(obj.raw_data)
                obj.index_10s(end) = [];
            end
        end

        function T = InitBoxTable(obj) % Initialize box table
            if obj.two_class
                T = table('Size',[length(obj.index_10s), 2],'VariableTypes',{'cell', 'cell'});
                T.Properties.VariableNames = [{'imageFilename'}, {'Peak'}];
            else
                T = table('Size',[length(obj.index_10s), 1 + obj.num_class],'VariableTypes',{'cell', 'cell', 'cell', 'cell', 'cell', 'cell', 'cell'});
                T.Properties.VariableNames = [{'imageFilename'}, obj.diseases];
            end
        end

        function obj = iterateEachWindow(obj)
            iteratorWindow = Iterator;
            iteratorWindow.list = obj.index_10s;
            iteratorWindow = iteratorWindow.first();
            while(~iteratorWindow.isDone())
                idxWindow = iteratorWindow.currentIndex();
                each_window_name = [obj.subjectName, '_', int2str(idxWindow)];
                obj.win_start = iteratorWindow.currentItem();
                obj.win_end = (obj.win_start + obj.time_window * obj.Fs - 1);
                signal_10s = obj.raw_data(obj.win_start : obj.win_end);
                filt_10s = obj.preProcessing(signal_10s);
                obj = obj.initLabel();
                obj = obj.iterateEachBeat(filt_10s, each_window_name); 
                
                obj = obj.saveData(idxWindow, each_window_name, filt_10s, signal_10s);
                iteratorWindow = iteratorWindow.next();
            end

        end

        function filt_10s = preProcessing(obj, signal_10s)
            % Filter
            filt_10s = fir_filter(signal_10s, obj.Fs);
            % Normalize
            filt_10s = normalize_min_max(filt_10s);
        end
        function obj = initLabel(obj)
            %% Label
            obj.win_SR = [];
            obj.win_APC = [];
            obj.win_VPC = [];
            obj.win_LBBB = [];
            obj.win_RBBB = [];
            obj.win_Others = [];
            obj.win_Peak = [];
            obj.py_single = [];
            obj.py_multi = [];
        
            select_label = (obj.sample < obj.win_end+1) & (obj.sample > obj.win_start);
            obj.win_label = obj.label(select_label);
            obj.win_sample = obj.sample(select_label) - obj.win_start;
        end

        function obj = iterateEachBeat(obj, filt_10s, each_window_name)
            iteratorBeat = Iterator;
            iteratorBeat.list = obj.win_label;
            iteratorBeat = iteratorBeat.first();
            obj.beatNum = 1;
            while(~iteratorBeat.isDone())
                beat = iteratorBeat.currentIndex;
                obj = obj.labelBbox(beat, filt_10s, each_window_name);

                iteratorBeat = iteratorBeat.next();
            end
        end

        function obj = labelBbox(obj, beat, filt_10s, each_window_name)
            if ~((obj.win_label(beat) == '+') || ((obj.win_sample(beat) - obj.beat_left) < 1) || ((obj.win_sample(beat) + obj.beat_right) > obj.Fs*obj.time_window))
%                 box_left = max((win_sample(beat) - beat_left), 1);
%                 box_right = min((win_sample(beat) + beat_right), 3600);
                box_left = obj.win_sample(beat) - obj.beat_left;
                box_right = obj.win_sample(beat) + obj.beat_right;
                box_min = max(min(filt_10s(box_left:box_right)) - obj.addtop, 0);
                box_max = min(max(filt_10s(box_left:box_right)) + obj.addtop, 1);  
                box_width = box_right-box_left;
                box_height = box_max-box_min;
                box_pos = [box_left, box_min, box_width, box_height]; % [x, y, width, height]
                
                %% Plot each beat
                sig = filt_10s(box_left:box_right);
                sig =  (sig-min(sig))/max(sig-min(sig));

%                 f_singlebeat = figure('visible','off');
%                 plot([1:length(sig)]/obj.Fs, sig)
%                 axis off; % 關閉圖軸
%                 set(gca,'XTick',[]);
%                 set(gca,'YTick',[]);
%                 set(gca,'Position',[0 0 1 1]);
%                 set(gcf, 'Position', [10 50 145.5 145.6])
%                 save_singleBeat = [obj.folder_save, '\singleBeat', '\',obj.subjectName, '\', each_window_name, '_', int2str(obj.beatNum), '.png'];
%                 saveas(f_singlebeat, save_singleBeat);
%                 close(f_singlebeat)

                obj.beatNum = obj.beatNum + 1;
                
                % Python coordinate
                box_x_py = ((box_left + box_right)/2 - 1)/(obj.Fs*obj.time_window-1);
                box_y_py = 1 - (box_min + box_max)/2;
                box_width_img = (box_right - box_left)/(obj.Fs*obj.time_window-1);
                box_height_img = (box_max - box_min);
                
                box_pos_py = [box_x_py, box_y_py, box_width_img, box_height_img];
                
                % signal_coordinate to image_coordinate for matlab
                box_left_img = round((box_left-1)*(obj.wanted_img_size(2)-1)/(obj.Fs*obj.time_window-1)+1);
                box_max_img = round((obj.wanted_img_size(1) + 1) - (box_max*(obj.wanted_img_size(1)-1)+1));
                box_width_img = round(box_width*(obj.wanted_img_size(2)-1)/(obj.Fs*obj.time_window-1));
                box_height_img = round(box_height*(obj.wanted_img_size(1)-1));
                box_pos_img = [box_left_img, box_max_img, box_width_img, box_height_img];

                if (obj.two_class == 1)
                    obj.win_Peak = [obj.win_Peak; box_pos_img];
                    obj.py_single = [obj.py_single; [0, box_pos_py]];
                else
                    switch obj.win_label(beat)
                        case {'N', '·'}
                            obj.win_SR = [obj.win_SR;box_pos_img];
                            obj.py_multi = [obj.py_multi; [0, box_pos_py]];
                        case 'A'
                            obj.win_APC = [obj.win_APC;box_pos_img];
                            obj.py_multi = [obj.py_multi; [1, box_pos_py]];
                        case 'V'
                            obj.win_VPC = [obj.win_VPC;box_pos_img];
                            obj.py_multi = [obj.py_multi; [2, box_pos_py]];
                        case 'L'
                            obj.win_LBBB = [obj.win_LBBB;box_pos_img];
                            obj.py_multi = [obj.py_multi; [3, box_pos_py]];
                        case 'R'
                            obj.win_RBBB = [obj.win_RBBB;box_pos_img];
                            obj.py_multi = [obj.py_multi; [4, box_pos_py]];
                        otherwise
                            obj.win_Others = [obj.win_Others;box_pos_img];
                            obj.py_multi = [obj.py_multi; [5, box_pos_py]];
                    end
                end
            end
        end

        function obj = saveData(obj, idxWindow, each_window_name, filt_10s, signal_10s)
            % Save .txt for python
%             if obj.two_class == 1
%                 writematrix(obj.py_single,[obj.folder_save, '\box\new\python\label_all\single\', each_window_name, '.txt'],'Delimiter',' ')
%             else
%                 writematrix(obj.py_multi,[obj.folder_save, '\box\new\python\label_all\multi\', each_window_name, '.txt'],'Delimiter',' ')  
%             end

            % Save signal
            save([obj.folder_save, obj.slash, 'mat', obj.slash, obj.subjectName, obj.slash, each_window_name, '.mat'], 'signal_10s');
            
            save_sig_axis = [obj.folder_save, obj.slash, 'signal_axis', obj.slash, obj.subjectName, obj.slash, each_window_name, '.png'];
            if obj.istwcc == 1
                save_sig = ['/home/tzuchienw1n/Tzu_Chien/PAG/FasterRCNN_MITBIH/data/signal_resize_20sec', '/',obj.subjectName, '/', each_window_name, '.png']; 
            else
                save_sig = [obj.folder_save, obj.slash, 'signal_resize', obj.slash, obj.subjectName, obj.slash, each_window_name, '.png'];
            end
%             save_signal(filt_10s, obj.Fs, save_sig_axis, save_sig, each_window_name, obj.isResize);
    
            % CWT
%             save_cwt_axis = [obj.folder_save, '\cwt_axis', '\',obj.subjectName, '\', each_window_name, '.png'];
%             save_cwt_only = [obj.folder_save, '\cwt',  '\',obj.subjectName, '\', each_window_name, '.png'];
%             save_cwt(filt_10s, obj.Fs, obj.fmin, obj.fmax, obj.fstep, save_cwt_axis, save_cwt_only, each_window_name);    
            
            % Box
            if obj.two_class
                obj.bboxTable{idxWindow,1:2} = [{save_sig}, {obj.win_Peak}];
            else
                obj.bboxTable{idxWindow,1:7} = [{save_sig}, {obj.win_SR}, {obj.win_APC}, {obj.win_VPC}, {obj.win_LBBB}, {obj.win_RBBB}, {obj.win_Others}];
            end
        end

        function saveBboxTable(obj)
            bboxTable = obj.bboxTable;
            %% Save BBox table
            save([obj.folder_save, obj.slash, 'box', obj.slash, 'new', obj.slash, 'matlab', obj.slash, char(string(obj.set_box_width(1))),  obj.type_name, obj.slash, obj.subjectName, obj.slash, 'T_', obj.subjectName, '.mat'], 'bboxTable');      
        end
    end
end