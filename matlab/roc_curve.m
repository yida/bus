% ROC
function roc_curve(TPR_set, FPR_set)
  random_gauss = 0 : 0.1 : 1;
  fig_roc = figure;
  plot(FPR_set, TPR_set, '*');
  hold on;
  h_gauss = plot(random_gauss, random_gauss, 'r--', 'LineWidth', 2);
  hold off;
  legend(h_gauss, 'Random Gauss');
  axis([0 1 0 1]);
  grid on;
  xlabel('False Position Rate');
  ylabel('True Position Rate');
  title('ROC space');
end
