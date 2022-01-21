function save_cwt(signal, s_rate, fmin, fmax, fstep, path_axis, path, img_title)
%% Spectrogram
taxis = [1:length(signal)]/s_rate;
spec = tfa_morlet(signal', s_rate, fmin, fmax, fstep); % CWT轉換參數 tfa_morlet(Input data, Samplerate, 轉換的最低頻率, 轉換的最高頻率, fstep)
faxis = fmin:fstep:fmax;   % 轉換頻域範圍，要與上面相同
Mag = abs(spec);     % get spectrum magnitude
 
%% Plot Spectrogram with title
f2 = figure('visible','off');
mesh(taxis,faxis,Mag)   % plot spectrogram as 3D mesh                
view(0,90);     % 將圖從立體轉為平面，轉90度   
axis on;
set(gca,'FontName','Times New Roman','FontSize',14) %改數字
set(gca, 'XTick', [0:fstep/2:length(signal)/s_rate])
set(gca, 'YTick', [0:2:fmax])
xlabel('Time (s)','Fontname', 'Times New Roman','FontSize',14,'FontWeight','bold')
ylabel('Frequency (Hz)','Fontname', 'Times New Roman','FontSize',14,'FontWeight','bold')  
title(img_title,'Fontname', 'Times New Roman','FontSize',18,'FontWeight','bold');
colorbar
saveas(f2, path_axis);

%% Only Spectrogram
axis off; % 關閉圖軸
set(gca,'XTick',[]);
set(gca,'YTick',[]);
set(gca,'Position',[0 0 1 1]);
set(gcf, 'Position', [10 50 145.5 145.6])

saveas(f2, path);
close(f2)
end