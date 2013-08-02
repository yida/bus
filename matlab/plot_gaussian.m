function plot_gaussian(MU, SIGMA)
  num_gau = size(MU, 2);
  figure;
  hold on;
  for i = 1 : num_gau
%    figure;
    mu = MU(:, i)';
    Sigma = SIGMA(:, :, i);

    x1 = -5:.2:5;
    x2 = -5:.2:5;
    [X1,X2] = meshgrid(x1,x2);
    F = -mvnpdf([X1(:) X2(:)],mu,Sigma);
    F = reshape(F,length(x2),length(x1));
    surf(x1,x2,F);
    caxis([min(F(:))-.5*range(F(:)),max(F(:))]);
    xlabel('x1'); ylabel('x2'); zlabel('Probability Density');
  end
end
