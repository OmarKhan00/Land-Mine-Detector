%% Setting up the device

daq.getDevices; % Identify the myDAQ device by checking device name

s = daq.createSession('ni'); %Create a data acquisition session
s.addAnalogInputChannel('myDAQ1',0:1,'Voltage');  %add all input channels(phototransistors)
s.Rate = 2000; %change scan rate to 2000 scans/second.
% s.DurationInSeconds = 2.0; %change duration of scan to 2 seconds.

%% Adding Input Channels

%Analog input channels (AI:0 red & AI:1 blue) connected to the two phototransistors. 
% addAnalogInputChannel(s,'myDAQ1','ai0','Voltage');
% addAnalogInputChannel(s,'myDAQ1','ai1','Voltage');


%Digital input channels (DI:0,DI:1) connected to micro-switches for bumpers.
s.addDigitalChannel('myDAQ1','port0/line0:1','InputOnly')


%% Adding Output Channels

%Analog output channel (AO:0) is connected to servo motor for claw.
s.addAnalogOutputChannel('myDAQ1','ao0','Voltage')

%Digital output channels (DO:4 & DO:5, DO:6&DO:7) are connected to the two DC motors
%DC motor 1 connects to DO:4 and DO:5.
%DC motor 2 co-nnects to DO:6 and DO:7.
s.addDigitalChannel('myDAQ1','port0/line4:7','OutputOnly')

%Digital output channel (DO:3) connects to the LED as an indicator.
s.addDigitalChannel('myDAQ1','port0/line3','OutputOnly')

%% Setting up the Parameters

led_off = 0;
led_on = 1;
claw_open = 6; %3.5
claw_closed = 3.5; %8.5
forward = [1 0];
backward = [0 1];
stop = [0 0];
minRed = 0.1; %confirm
maxRed = 0.3;
minBlue = 1.2;
maxBlue = 1.5;
% minBlackTape = 0.07; %Test
% maxBlackTape = 0.13; %Test
BlackTape = 0.15; %Test

%% Setting up the loop
while (true)
    input_data = inputSingleScan(s)
   % data : 1 * 4
    % data(1): Phototransistor connected to the bottom of the device 
    % data(2): Transistor connected to the Claw
    % data(3): Right Switch
    % data(4): Left Switch
    
    if input_data(2)>= minRed && input_data(2)<= maxRed %if it detects a red puck
        red_detected = 1;
        disp('see red puck')
        output_data=[claw_closed forward forward led_on];   
        s.outputSingleScan(output_data);
%         pause(0.1); %Test
        if input_data(1) < BlackTape %determines the locale of the black tape
           red_detected = 1;
           disp('see blacktape')
           output_data = [claw_closed forward forward led_on];   
           s.outputSingleScan(output_data);
           pause(0.7);
           output_data = [claw_open stop stop led_off];  
           s.outputSingleScan(output_data);
           pause(0.2);
           output_data = [claw_open backward backward led_off]; 
           s.outputSingleScan(output_data);
           pause(1.3); %Test
           output_data = [claw_open forward backward led_off];  
           s.outputSingleScan(output_data);
           pause(0.5)
           red_detected = 0;
%            pause(1);
        end
    elseif input_data(2)>= minBlue && input_data(2)<= maxBlue %if it finds blue puck
        red_detected = 0;
        disp('see blue buck')
        output_data=[claw_open stop stop led_off];   
        s.outputSingleScan(output_data);
        pause(0.3);
        output_data=[claw_open backward backward led_off];   
        s.outputSingleScan(output_data);
        pause(0.5); 
        output_data=[claw_open forward backward led_off];   
        s.outputSingleScan(output_data);
         pause(0.1); 
    else
           red_detected = 0;
           output_data=[claw_open forward forward led_off];  
           s.outputSingleScan(output_data);
%            pause(0.1);
           if input_data(1) < BlackTape %finds tape without puck
           disp('see blacktape')
           output_data=[claw_open stop stop led_off];   % output_data : 1*5
           s.outputSingleScan(output_data);
           pause(0.1);
           output_data = [claw_open backward backward led_off]; 
           s.outputSingleScan(output_data);
           pause(0.7); %Test
           output_data=[claw_open forward backward led_off];   % output_data : 1*5
           s.outputSingleScan(output_data);
           pause(0.4)
%            pause(1);
           end
    end
    
     if input_data(3)==1 || input_data(4)==1 %let bumper hits
         disp('hits the wall')
         if red_detected == 0
           output_data=[claw_open stop stop led_off];  
           s.outputSingleScan(output_data);
           pause(0.2);
           output_data=[claw_open backward backward led_off];   
           s.outputSingleScan(output_data);
           pause(0.5);
           output_data=[claw_open forward backward led_off];   
           s.outputSingleScan(output_data);
           pause(0.1);
%            output_data=[claw_open forward forward led_off];   
%            s.outputSingleScan(output_data);
%            pause(0.05);
         else
           output_data=[claw_closed stop stop led_on];  
           s.outputSingleScan(output_data);
           pause(0.2);
           output_data=[claw_closed backward backward led_on];   
           s.outputSingleScan(output_data);
           pause(0.7);
           output_data=[claw_closed forward backward led_on];   
           s.outputSingleScan(output_data);
           pause(0.4);
%            output_data=[claw_closed forward forward led_on];   
%            s.outputSingleScan(output_data);
         end
     end
end
s.release();