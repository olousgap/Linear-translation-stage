%XY Code for communicating with an instrument.
%
%   This is the machine generated representation of an instrument control
%   session. The instrument control session comprises all the steps you are
%   likely to take when communicating with your instrument. These steps are:
%   
%       1. Create an instrument object
%       2. Connect to the instrument
%       3. Configure properties
%       4. Write and read data
%       5. Disconnect from the instrument
% 
%   To run the instrument control session, type the name of the file,
%   XY, at the MATLAB command prompt.
% 
%   The file, XY.M must be on your MATLAB PATH. For additional information 
%   on setting your MATLAB PATH, type 'help addpath' at the MATLAB command 
%   prompt.
% 
%   Example:
%       xy;
% 
%   See also SERIAL, GPIB, TCPIP, UDP, VISA.
% 
 
%   Creation time: 22-Nov-2011 13:42:15

% Find a GPIB object.
obj1 = instrfind('Type', 'gpib', 'BoardIndex', 1, 'PrimaryAddress', 13, 'Tag', '');

% Create the GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = gpib('NI', 1, 13);
else
    fclose(obj1);
    obj1 = obj1(1)
end

% Connect to instrument object, obj1.
fopen(obj1);

% Configure instrument object, obj1.
set(obj1, 'EOSMode', 'read&write');
set(obj1, 'Timeout', 1.0);

% Communicating with instrument object, obj1.

%fprintf(obj1, 'I1O');
%fprintf(obj1, 'I2O');
%fprintf(obj1, 'C1=+000000!');
%fprintf(obj1, 'C2=+000000!');
%fprintf(obj1, 'VR1');
%fprintf(obj1, 'VR2');

dim=input('Set Dimension in um');
t=dim/2*1;
for n=1:t
    fprintf(obj1, 'I1=+000100!');
    sync;
    fprintf(obj1, 'I2=+000010!');
    sync;
    fprintf(obj1, 'I1=-000100!');
    sync;
    fprintf(obj1, 'I2=+000010!');
    sync;
end
fprintf(obj1, 'I1=+000100!');

% Disconnect from instrument object, obj1.
fclose(obj1);

% Clean up all objects.
delete(obj1);

