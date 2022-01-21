function save_signal(signal, Fs, path_axis, path, img_title, isResize)
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
        set(gcf, 'Position', [10 50 435.8 145.6])
    else
        set(gcf, 'Position', [10 50 145.5 145.6])
    end
    saveas(f1, path);
close(f1)
end