clear all;
%%
folders = dir("subjects");
task = "levelground/";
tasks = ["ramp" "stair"];
timeseries = ["conditions/" "emg/" "gcRight/" "ik/" "imu/"];
gc_sensors = ["HeelStrike"];
emg_sensors = ["gastrocmed" "vastusmedialis" "vastuslateralis" "tibialisanterior" "rectusfemoris" "bicepsfemoris"];
ik_sensors = ["knee_angle_r" "ankle_angle_r"];
for k=1:length(tasks)
    for j=3:length(folders)
        folder = strcat("subjects/",folders(j).name);
        % get all the file names
        cond_files = dir(strcat(folder,"/",tasks(k),"/","conditions/"));
        cond_files = cond_files(3:end);
        emg_files = dir(strcat(folder,"/",tasks(k),"/","emg/"));
        emg_files = emg_files(3:end);
        gc_files = dir(strcat(folder,"/",tasks(k),"/","gcRight/"));
        gc_files = gc_files(3:end);
        ik_files = dir(strcat(folder,"/",tasks(k),"/","ik/"));
        ik_files = ik_files(3:end);
        imu_files = dir(strcat(folder,"/",tasks(k),"/","imu/"));
        imu_files = imu_files(3:end);
    
    % load the files for each time series
        for i=1:length(cond_files)
            cond_file = load(strcat(folder,"/",tasks(k),"/","conditions/",cond_files(i).name));
            emg_file = load(strcat(folder,"/",tasks(k),"/","emg/",emg_files(i).name));
            gc_file = load(strcat(folder,"/",tasks(k),"/","gcRight/",gc_files(i).name));
            ik_file = load(strcat(folder,"/",tasks(k),"/","ik/",ik_files(i).name));
            imu_file = load(strcat(folder,"/",tasks(k),"/","imu/",imu_files(i).name));
            
            % find the rows of data that we care about
            indices = ones(length(cond_files),1);
            if tasks(k)=="levelground"
                indices = ismember(cond_file.labels.Label,'walk');
            elseif tasks(k)=="stair"
                i1 = ismember(cond_file.labels.Label,'stairdescent');
                i2 = ismember(cond_file.labels.Label,'stairascent');
                indices = i1 | i2;
            elseif tasks(k)=="ramp"
                i1 = ismember(cond_file.labels.Label,'rampdescent');
                i2 = ismember(cond_file.labels.Label,'rampascent');
                indices = i1|i2;
            else
                continue;
            end
            timestamps = gc_file.data(indices,1).Variables;
            
            % filter the data to remove idle and stand conditions
            gc = gc_file.data(indices,:);
            imu = imu_file.data(indices,2:end);
            ik = ik_file.data(indices,ik_sensors);
            % emg has to be decimated 5x, how do we do this?
            % a moving average would do the trick
            emg = filter_emg(emg_file.data,timestamps,emg_sensors);
            
            % data labels
            actions = label_action(tasks(k),cond_file.labels.Label(indices));
            contact_mode = label_contact_mode(gc.HeelStrike,gc.ToeOff);
            phase = 2*pi/100*gc.HeelStrike;
            
            % now we should be able to assemble the data into one large table
            % and save it as a CSV
            
            label_table = array2table([timestamps actions contact_mode phase], "VariableNames", ["Timestamp" "Action" "ContactMode" "Phase"]);
            
            big_table = [label_table imu emg(:,2:end) ik];
        
            % save the data to disk
            outfile = strcat("csv_data/", strrep(folder,"/","_"),"_", strrep(cond_files(i).name,".mat",".csv"));
            writetable(big_table,outfile)
        end
    end
end
