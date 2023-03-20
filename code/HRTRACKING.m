classdef HRTRACKING
    methods(Static)
        function [filter_data] = fir_lpf_4Hz_conv(data, fs)
            %% STUDENT: DO SOMETHING BELOW 
            omega_cut = (230/60)/fs*2*pi; % edge frequency of passband
            omega_stop = (250/60)/fs*2*pi; % edge frequency of stopband
            domega = omega_stop-omega_cut;
            omega_c = (omega_cut + omega_stop)/2;
            N = ceil(2*pi/domega);
            n = [0:1:(2*N)]; 
            m = n- N; %SHIFT 
            h = omega_c/pi * sinc(omega_c/pi * m);
            filter_data = conv(data,h);
            filter_data = filter_data((length(h)-1)/2:length(data)+(length(h)-1)/2-1);
            %% STUDENT: DO SOMETHING ABOVE 
        end
        
        function [filter_data] = fir_hpf_conv(data, fs)
            %% STUDENT: DO SOMETHING BELOW
            omega_cut = ((1479/60)/fs)*2*pi; % edge frequency of passband
            omega_stop = ((1481/60)/fs)*2*pi; % edge frequency of stopband
            domega = omega_stop-omega_cut;
            omega_c = (omega_cut + omega_stop)/2;
            N = ceil(2*pi/domega);
            n = [0:1:(2*N)]; 
            m = n - N; %SHIFT 
            h = omega_c/pi * sinc(omega_c/pi * m);
            for i = 1:length(h)
                hp(i) = h(i) * (-1)^i;
            end
            filter_data = conv(data,hp);
            filter_data = filter_data((length(h)-1)/2:length(data)+(length(h)-1)/2-1);
            %% STUDENT: DO SOMETHING ABOVE 
        end
        
        function [availability] = availability(hr_bpm, golden_hr)
            availability = length(5);
            avaiable_bpm_range = [3, 5, 10, 15, 20]
                %% STUDENT: DO SOMETHING BELOW
            for n = 1:5
                sum = 0;
                for i = 1:length(golden_hr)
                    if(abs(hr_bpm(i)-golden_hr(i)) < avaiable_bpm_range(n))
                        sum = sum + 1;
                    end
                end
                availability(n) = sum / length(golden_hr);
            end
                
                %% STUDENT: DO SOMETHING ABOVE 
        end
    end
end
