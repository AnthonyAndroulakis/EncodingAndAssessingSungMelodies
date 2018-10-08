figure;
plot(1:length(newsong),newsong*1.5)
%plot(1:length(newsong),newsong*1.5)
hold on
plot(x,y, 'LineWidth', 3)
title([sprintf('Graph of Signal in Decibels and Treetop Envelope of Signal for Patient ') filename(end-12:end-4)],'Interpreter', 'none');
xlabel('Frames (44100 frames = 1 second)') % x-axis label
ylabel('Decibels') % y-axis label
legend('Signal (decibels)','Treetop Envelope')
saveas(gcf,'papergraph3.png')

