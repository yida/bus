function TPR = true_positive_rate(TP, FP, FN, TN)
  TPR = TP / (TP + FN);
end
