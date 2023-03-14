function labels = label_contact_mode(heelstrike, toeoff)
    labels = zeros(length(heelstrike),1);
    j = 1;
    while heelstrike(j) ~= 0
        j = j + 1;
    end
    state = 0;
    while j > 0
        if state == 0 && toeoff(j) == 0
            state = 1;
        end
        j = j-1;
    end
    for j = 1:length(heelstrike)
        if state == 1 && toeoff(j) == 0
            state = 0;
        elseif state == 0 && heelstrike(j) == 0
            state = 1;
        end
        labels(j) = state;
    end
end