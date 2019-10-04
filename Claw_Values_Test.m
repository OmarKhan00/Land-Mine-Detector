s = daq.createSession('ni');
s.addAnalogOutputChannel('myDAQ1',0:1, 'Voltage');
for i=1:2
  s.outputSingleScan([7 0]);
  pause(1.0);
  s.outputSingleScan([0 5]);
  pause(1.0);
end
s.release();
