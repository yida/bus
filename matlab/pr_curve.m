% PR
function pr_curve(P_set, R_set)
  fig_pr = figure;
  plot(R_set, P_set, '*');
  hold on;
  axis([0 1 0 1]);
  grid on;
  xlabel('Recall');
  ylabel('Precision');
  title('PR space');
end
