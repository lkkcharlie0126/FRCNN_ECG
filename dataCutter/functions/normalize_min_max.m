function output_signal = normalize_min_max(input_signal)
    temp = input_signal - min(input_signal);
    output_signal = temp ./ max(temp);
end