function labels = label_action(task,condition_labels)
    labels = zeros(length(condition_labels),1);
    for j=1:length(condition_labels)
        x = cell2mat(condition_labels(j));
        if task == "walk"
            labels(j) = 0;
        elseif task=="stair"
            if ismember(condition_labels(j),"stairdescent")
                labels(j) = 1;
            else
                labels(j) = 2;
            end
        elseif task=="ramp"
            if ismember(condition_labels(j),"rampdescent")
                labels(j) = 3;
            else
                labels(j) = 4;
            end
        end
    end
end