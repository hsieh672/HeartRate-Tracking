# HeartRate-Tracking
The PPG signal is collected at the wrist by a watch. There are three types of noise that need to be eliminated.  
The format of data.csv: A: PPG-G(*7.5*10^-7 = uA), B: ACC-X, C: ACC-Y, D: ACC-Z. Sampling rate of photoplethysmography (PPG) and accelerator (ACC) signals are 50Hz.  
The data in golden.csv: The heart rate which use to calculate the Availability Percentage (AP).   
## Low Pass filter
The cut off frequency of the low pass filter is 240/60 (Hz), so I set up the edge frequency of passband and the edge frequency of stopband to the first two steps of the following figure, then the cut off frequency would be  
### (𝜔𝑝𝑎𝑠𝑠𝑏𝑎𝑛𝑑 +𝜔𝑠𝑡𝑜𝑝𝑏𝑎𝑛𝑑) ∗ (1/2)  

Next, created a rectangular window and shifted it to the right to make sure it is causal. Finally, y[n] = x[n]*h[n], the output data equivalent to the input data convolves the impulse response.  

```sh
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
```

## High Pass filter
Used the same way to construct a low pass filter I built in the previous section.  
Used the equation as the following to change the low pass filter to a high pass filter.  
![equation](https://github.com/hsieh672/HeartRate-Tracking/blob/main/imag/equation.png)

##  Spectrum Denoise
Used PPG signal subtracted three noise signal：ACC-X, ACC-Y, ACC-Z signals and then normalized it.  

## Availability Percentage (AP)
```sh
cd dillinger
npm i
node app
```

| AP3    | AP5    | AP10   | AP15   | AP20   |
|--------|--------|--------|--------|--------|
| 0.9094 | 0.9475 | 0.9829 | 0.9921 | 0.9974 |

