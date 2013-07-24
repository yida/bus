function samples = imu_sample_merge(imu_samples, imu_cells)
  cell_num = numel(imu_cells);
  sample_num = numel(imu_samples);
  samples = imu_samples;
  for i = 1 : cell_num
    samples{sample_num + 1} = imu_cells{i};
    sample_num = sample_num + 1;
  end
end
