function output_signal = normalize_mean_max(input_signal)
temp = input_signal - mean(input_signal);
output_signal = temp ./ max(abs(temp));
end