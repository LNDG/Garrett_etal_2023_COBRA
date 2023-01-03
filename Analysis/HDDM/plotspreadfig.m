function ax = plotspreadfig(data, Fontsize, condlabels, SUBJ)
% lines between pts
% line([ones(1,size(data,1)); ones(1,size(data,1))+1], [data(:,1) data(:,2)]', 'Color',[0.66 0.66 0.66 ], 'Linewidth', 0.5)

handle = plotSpread( num2cell(data,1), 'distributionMarkers', 'o', 'distributionColors', [1 0.5 0.5; 0.5 0.5 1; 0.5 1 0.5] );% b r circles
% handle = plotSpread( num2cell(data,1), 'distributionMarkers', 'o' );% b r circles
set(handle{1}(1:end), 'MarkerSize', 3, 'Linewidth', 0.5)
% text(data(:,1)', data(:,2)', num2cell(SUBJ), 'Fontsize', Fontsize)

ax=gca;
ax.FontSize = Fontsize;
ax.XTickLabel = condlabels;

% % mean lines black
% width = 0.7;
% cols = {'k'};
% for i=1:size(data,2)
%   line([i-width/2 i+width/2]', [nanmean(data(:,i)) nanmean(data(:,i))]',  'Color', cols{1}, 'Linewidth', 2)
% end
% mean lines
width = 0.7;
cols = {'r' 'b' 'g'};
for i=1:size(data,2)
  line([i-width/2 i+width/2]', [nanmean(data(:,i)) nanmean(data(:,i))]',  'Color', cols{i}, 'Linewidth', 2)
end
% line([0.75 1.25]', [mean(data(:,1)) mean(data(:,1))]',  'Color', 'r', 'Linewidth', 2)
% line([1.75 2.25]', [nanmean(data(:,2)) nanmean(data(:,2))]',  'Color', 'b', 'Linewidth', 2)
% line([2.75 3.25]', [nanmean(data(:,3)) nanmean(data(:,3))]',  'Color', 'g', 'Linewidth', 2)

% stats
% [~,p] = ttest(data(:,1), data(:,2));
% text(1, ax.YLim(2), sprintf('p=%1.3f', p), 'Fontsize', Fontsize)
%   if p < 0.05 %   sigstar
% xlim([0.5 2.5])

