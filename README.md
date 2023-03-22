# HeartRate-Tracking
The PPG signal is collected at the wrist by a watch. There are three types of noise that need to be eliminated.
## Low Pass filter
The cut off frequency of the low pass filter is 240/60 (Hz), so I set up the edge frequency of passband and the edge frequency of stopband to the first two steps of the following figure, then the cut off frequency would be (𝜔𝑝𝑎𝑠𝑠𝑏𝑎𝑛𝑑 +𝜔𝑠𝑡𝑜𝑝𝑏𝑎𝑛𝑑) ∗ (1/2).  
Next, created a rectangular window and shifted it to the right to make sure it is causal. Finally, y[n] = x[n]*h[n], the output data equivalent to the input data convolves the impulse response.  


## High Pass filter
Used the same way to construct a low pass filter I built in the previous section.  
Used the equation as the following to change the low pass filter to a high pass filter.  
![equation](https://github.com/hsieh672/HeartRate-Tracking/blob/main/imag/equation.png)

