%clear;
%loadspice('Final_Simulation.txt')
figure;
plot(time{1,65}, vout{1,65})
xlabel('Time (seconds)')
ylabel('Voltage out of hysteretic Oscillator (volts)')
%figure;
%plot(time{1,44}, vout{1,44})
figure;
for T = 1:65
    hold on
    plot(time{1,T}, vout{1,T})
    xlabel('Time (seconds)')
    ylabel('Voltage out of hysteretic Oscillator (volts)')
end
period_collection = zeros(65,1);
error_collection = zeros(65,1);
for cell = 1:65
    count = 0;
    x = zeros(1,1);
    for index = (vout{1,cell})
        count = count + 1;
        if index > 3.27
            x(count,1) = 1;
        end
    end
    counter = 0;
    mat = zeros(1,1);
    for j = 1:length(x) 
        if j == 1
            counter = counter + 1;
            mat(counter,1) = 0;
        elseif x(j,1) - x(j - 1,1) == 1
            counter = counter + 1;
            mat(counter,1) = j;
        end
    end
    interval = mat(2:end,1);
    upwards = 0;
    time_matrix = zeros(1,1);
    for w = time{1,cell}
        upwards = upwards + 1;
        time_matrix(upwards,1) = w;
    end
    time_scale = zeros(length(interval),1);
    for q = 1:length(interval)
        time_scale(q,1) = time_matrix(interval(q,1),1);
    end
        period = time_scale(6,1) - time_scale(5,1);
%         if period < .6 && period > .4
%             period = period * 2;
%         end
        period_collection(cell,1) = period;
        error = (abs((1-period)/1) * 100);
        error_collection(cell,1) = error;
end
figure;
plot(error_collection,'*')
xlabel('Component value sweep')
ylabel('Error amount from ideal period (%)')
figure;
plot(period_collection,'*')
xlabel('Component value sweep')
ylabel('Period (seconds)')