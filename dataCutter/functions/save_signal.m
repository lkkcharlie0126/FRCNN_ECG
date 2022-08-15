function save_signal(signal, signalRaw, Fs, path_axis, path_axis_raw, path, img_title, isResize)
f1 = figure('visible','off');
% Signal with axis
    plot([1:length(signal)]/Fs, signal);
    xlabel('Time (s)','Fontname', 'Times New Roman','FontSize',14,'FontWeight','bold')
    ylabel('Amplitude (Normalized)','Fontname', 'Times New Roman','FontSize',14,'FontWeight','bold')  
    title(img_title,'Fontname', 'Times New Roman','FontSize',18,'FontWeight','bold');
%     saveas(f1, path_axis);
% Signal only
    axis off; % 關閉圖軸
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
    set(gca,'Position',[0 0 1 1]);
    if isResize
        % 681
        set(gcf, 'Position', [10 50 435.8 145.6])
        % 241
%         set(gcf, 'Position', [10 50 154 145.6])
        % 256
%         set(gcf, 'Position', [10 50 164 145.6])
        % 260
%         set(gcf, 'Position', [10 50 166.6 145.6])
    else
        set(gcf, 'Position', [10 50 145.5 145.6])
    end
%     saveas(f1, path);
close(f1)

f2 = figure('visible','off');
% Signal with axis
    plot([1:length(signalRaw)]/Fs, signalRaw);
    xlabel('Time (s)','Fontname', 'Times New Roman','FontSize',14,'FontWeight','bold')
    ylabel('Amplitude','Fontname', 'Times New Roman','FontSize',14,'FontWeight','bold')  
    title(img_title,'Fontname', 'Times New Roman','FontSize',18,'FontWeight','bold');
    saveas(f2, path_axis_raw);
close(f2);
end