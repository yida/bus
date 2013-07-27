
scrz = get(0, 'screensize');
width = 1300;
height = 400;

sample_num = numel(sample);
fig = figure('Position', [scrz(3)/2 - width/2, scrz(4)/2 - height/2,...
                          width, height]);

sample_num_div = ceil(sample_num / 2);

sample_left_ts = [];
sample_left_value = [];
sample_right_ts = [];
sample_right_value = [];

span_left_ts_array = [];
span_left_ts_counter = 1;
span_right_ts_array = [];
span_right_ts_counter = 1;

sample_counter = 1;
for i = 1 : 2
  for j = 1 : sample_num_div
    if sample_counter <= sample_num
      centralized_ts = centralize(sample{sample_counter}.ts, sample{sample_counter}.wy);
      [sigma, mu] = gaussfit(centralized_ts, sample{sample_counter}.wy);
      span_ts = sample{sample_counter}.ts(end) - sample{sample_counter}.ts(1);
      if sample{sample_counter}.label == 1
        sample_left_ts = [sample_left_ts, centralized_ts];
        sample_left_value = [sample_left_value, sample{sample_counter}.wy];
        y = 1/(sqrt(2 * pi * sigma)) * gaussmf(centralized_ts, [sigma, mu]);
        span_left_ts_array(span_left_ts_counter) = span_ts;
        span_left_ts_counter = span_left_ts_counter + 1;
      else
        sample_right_ts = [sample_right_ts, centralized_ts];
        sample_right_value = [sample_right_value, sample{sample_counter}.wy];
        y = -1/(sqrt(2 * pi * sigma)) * gaussmf(centralized_ts, [sigma, mu]);
        span_right_ts_array(span_right_ts_counter) = span_ts;
        span_right_ts_counter = span_right_ts_counter + 1;
      end
      subplot(2, sample_num_div, sample_counter);
      plot(centralized_ts, sample{sample_counter}.wy, '*');
      hold on;
      plot(centralized_ts, y, 'r.');
      hold off;
      grid on;
      sample_counter = sample_counter + 1;
    end
  end
end

span_left_ts = mean(span_left_ts_array);
span_right_ts = mean(span_right_ts_array);

figure;
plot(sample_left_ts, sample_left_value, '.');
hold on;
[sigma_left, mu_left] = gaussfit(sample_left_ts, sample_left_value);
y_left = 1/(sqrt(2 * pi * sigma_left)) * gaussmf(sample_left_ts, [sigma_left, mu_left]);
plot(sample_left_ts, y_left, 'r.');
grid on;

figure;
plot(sample_right_ts, sample_right_value, '.');
hold on;
[sigma_right, mu_right] = gaussfit(sample_right_ts, sample_right_value);
y_right = -1/(sqrt(2 * pi * sigma_right)) * gaussmf(sample_right_ts, [sigma_right, mu_right]);
plot(sample_right_ts, y_right, 'r.');
grid on;
