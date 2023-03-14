function out_table = filter_emg(in_table, timestamps, sensors)
    % decimating EMG using a moving average
    out_vars = zeros(size(timestamps,1),1+length(sensors));
    out_vars(:,1) = timestamps;
    i = 1;
    for j = 1:size(timestamps,1)
        while in_table.Header(i) < timestamps(j)
            i = i+1;
        end
        % calculate an average for this window
        X = in_table(i-4:i,sensors).Variables;
        out_vars(j,2:end) = mean(X);
    end
    names = ["Header" sensors];
    out_table = array2table(out_vars, "VariableNames", names);
end