%Acquire Analog Input Data in the Foreground
d = daq.getDevices
%Create a session object and save it to the variable, s: 
s = daq.createSession('ni')  
%Configure the sampling rate at 1000 scans per second. 
s.Rate = 1000;

addAnalogInputChannel(s,'myDAQ3','ai0','Voltage')
addAnalogInputChannel(s,'myDAQ3','ai1','Voltage')

while 1 
     input_data = inputSingleScan(s)
     plot(input_data)
     pause(0.01)
end