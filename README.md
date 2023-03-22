# HeartRate-Tracking
The PPG signal is collected at the wrist by a watch.  
There are three types of noise that need to be eliminated.  
The format of data.csv: A: PPG-G(*7.5*10^-7 = uA), B: ACC-X, C: ACC-Y, D: ACC-Z. Sampling rate of photoplethysmography (PPG) and accelerator (ACC) signals are 50Hz.  
The data in golden.csv: The heart rate which use to calculate the Availability Percentage (AP).   
## Low Pass filter
The cut off frequency of the low pass filter is 240/60 (Hz), so I set up the edge frequency of passband and the edge frequency of stopband to the first two steps of the following figure, then the cut off frequency would be  
### (𝜔𝑝𝑎𝑠𝑠𝑏𝑎𝑛𝑑 +𝜔𝑠𝑡𝑜𝑝𝑏𝑎𝑛𝑑) ∗ (1/2)  

Next, created a rectangular window and shifted it to the right to make sure it is causal.  
Finally, y[n] = x[n]*h[n], the output data equivalent to the input data convolves the impulse response.  

```sh
function [filter_data] = fir_lpf_4Hz_conv(data, fs)
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
        end
```

## High Pass filter
Used the same way to construct a low pass filter I built in the previous section.  
Used the equation as the following to change the low pass filter to a high pass filter.  

![equation](https://github.com/hsieh672/HeartRate-Tracking/blob/main/imag/equation.png)

```sh
function [filter_data] = fir_hpf_conv(data, fs)
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
        end
```

##  Spectrum Denoise
Used PPG signal subtracted three noise signal：ACC-X, ACC-Y, ACC-Z signals and then normalized it.  

```sh
    denoise_fft(sim_timer, :) = 0;
    denoise_ffti = abs(ppg_ffti - (accx_ffti + accy_ffti + accz_ffti));
    denoise_fft(sim_timer, :) = denoise_ffti/max(denoise_ffti);
```
## HR tracking
Find the index of the maximum value between 20 and 90 in every second. Controlled range ensures more precise answers. Because of the denoise signal in every second is between lowR(28) and highR(165), so I rescaled the hr_track from 65 to 170 to make sure it shares a y-axis with golden_hr data.

```sh 
    hr_track(sim_timer) = 0;
    [val , idx] = max(denoise_fft(sim_timer, 20:90));
    hr_track(sim_timer) = idx;
    sim_timer = sim_timer + 1; 
```

```sh
    hr_track = round(rescale(hr_track,65,170));
```

## Availability Percentage (AP)
Used the formula as the following figure to find AP. From the definition, when available bpm range becomes larger, the availability becomes higher. The answer I got also verifies this inference.  

![AP](https://github.com/hsieh672/HeartRate-Tracking/blob/main/imag/AP.png)  

```sh
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
```
 ## Simulation Results
 
 ![simulation](https://github.com/hsieh672/HeartRate-Tracking/blob/main/imag/simulation.png)   
 
| AP3    | AP5    | AP10   | AP15   | AP20   |
|--------|--------|--------|--------|--------|
| 0.9094 | 0.9475 | 0.9829 | 0.9921 | 0.9974 |

