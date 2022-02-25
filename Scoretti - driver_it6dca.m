function varargout = driver_it6dca (tags, command, varargin)

% DRIVER_IT6DCA               driver of the microcontrole IT6DCA1/2
%
% DESCRIPTION :               This m-file deals with the systems microcontrole IT6DCA1 and IT6DCA2. The
%                             first argument is the command to be executed. The others command, depending
%                             upon the command, may be of the form :
%                             - <axes>       vector containing the selected axes (i.e. [1 3])
%                             - <position>   vector of the coordinates in [mm] (nan = doesn't apply)
%                             - <sync mode>  it may be 'sync' (default) or 'async'
%
% INPUT :                     
% - tags                      headers to communicate with the instrument
% - command                   command to execute :
%                             'init'               ... calibrate the position of the axes
%                             'reset' <axes>       ... set the counter of the selected axes to zero
%                             'go to' <position>   ... move the arm to the given position (nan = don't move
%                                                      the arm along the direction)
%                             'locate'             ... get the position of the arm
%                             'status'             ... get the status of the arm ; it may be :
%                                                        0   = stopped
%                                                        +1  = max. position
%                                                        -1  = min. position
%                                                        nan = moving
%                             'fast' <axes>        ... set the high speed mode
%                             'slow' <axes>        ... set the low speed mode
%                             'synchronise'        ... wait untill the arm is stopped
%                                
% - ...                       parameters (depending upon the command)
%
% OUTPUT :                    
% - ...                       measurement (depending upon the command)
%
% NOTES :                     1\ requires the MEX-function gpibwriteln(.), gpibreadln(.)
%                             2\ the microcontrole must be connected to the IEEE 488 bus with the
%                                address 8 and 9
%
% DATE :                      21-Feb-2003

% --------------------------->| description of the function ----------------------------------------------->| remarks

switch lower(command)                                                                                       % parsing of the command
case {'init', 'initialisation', 'initialization', 'origin', 'home'}
   [choice, synchronous_mode] = parse_parameters (varargin{:});
   if choice(3), gpibwriteln (tags{1}, 'I1O', 10); end
   if choice(1) & choice(2)
      gpibwriteln (tags{2}, 'IIO', 10);
   elseif choice(1) & ~choice(2)
      gpibwriteln (tags{2}, 'I1O', 10);
   elseif ~choice(1) & choice(2)
      gpibwriteln (tags{2}, 'I2O', 10);
   end
   if synchronous_mode, driver_it6dca (tags, 'synchronise'); end
case {'zero', 'reset'}
   [choice, synchronous_mode] = parse_parameters (varargin{:});
   if choice(1), gpibwriteln (tags{2}, 'C1O', 10); end
   if choice(2), gpibwriteln (tags{2}, 'C2O', 10); end
   if choice(3), gpibwriteln (tags{1}, 'C1O', 10); end
case {'status'}
   buff = [nan nan nan];
   answr{1} = gpibreadln (tags{2}, 'I1?', 10);
   answr{2} = gpibreadln (tags{2}, 'I2?', 10);
   answr{3} = gpibreadln (tags{1}, 'I1?', 10);
   for k = 1:3
     switch (upper(answr{k}([1 2])))
      case 'AR'
         buff(k) = 0;
      case 'F+'
         buff(k) = +1;
      case 'F-'
         buff(k) = -1;
      case 'DE'
         buff(k) = nan;
      case 'RO'
         buff(k) = nan;
      end
   end
   varargout{1} = buff;
case {'move', 'go to', 'goto'}
   pos = varargin{1};
   [choice, synchronous_mode] = parse_parameters (varargin{2:end});
   if ~isnan(pos(1)), gpibwriteln (tags{2}, sprintf ('I1=%+07d!', round(10*pos(1))), 10); end
   if ~isnan(pos(2)), gpibwriteln (tags{2}, sprintf ('I2=%+07d!', round(10*pos(2))), 10); end
   if ~isnan(pos(3)), gpibwriteln (tags{1}, sprintf ('I1=%+07d!', round(100*pos(3))), 10); end
   if synchronous_mode, driver_it6dca (tags, 'synchronise'); end
case {'position', 'pos', 'locate', 'where'}
   pos = [nan nan nan];
   pos(1) = sscanf (gpibreadln (tags{2}, 'C1?', 10), 'C1=%d')/10;
   pos(2) = sscanf (gpibreadln (tags{2}, 'C2?', 10), 'C2=%d')/10;
   pos(3) = sscanf (gpibreadln (tags{1}, 'C1?', 10), 'C1=%d')/100;
   varargout{1} = pos;
case {'synchronize', 'synchronise', 'synchro', 'sync'}   
   status = driver_it6dca (tags, 'status');
   while isnan(status(1)*status(2)*status(3))
      status = driver_it6dca (tags, 'status');
   end
case {'high speed', 'quick', 'quickly', 'fast'}
   [choice, synchronous_mode] = parse_parameters (varargin{2:end});
   if choice(1), gpibwriteln (tags{2}, 'VR1', 10); end
   if choice(2), gpibwriteln (tags{2}, 'VR2', 10); end
   if choice(3), gpibwriteln (tags{1}, 'VR1', 10); end
case {'low speed', 'slow', 'slowly'}
   [choice, synchronous_mode] = parse_parameters (varargin{2:end});
   if choice(1), gpibwriteln (tags{2}, 'VL1', 10); end
   if choice(2), gpibwriteln (tags{2}, 'VL2', 10); end
   if choice(3), gpibwriteln (tags{1}, 'VL1', 10); end   
otherwise
   error (['unknown command <', command, '>']);
end
return



function [choice, synchronous_mode] = parse_parameters (varargin)
synchronous_mode = 1;                                                                               % by default, work on all the axes in synchronous mode
choice = [1 1 1];
for k = 1:length(varargin),
   if isa(varargin{k}, 'char')
      switch lower(varargin{k})    
      case {'sync', 'synchro', 'synchronous mode', 'synchronous', 'synchronously'}
         synchronous_mode = 1;
      case {'async', 'asynchro', 'asynchronous mode', 'asynchronous', 'asynchronously'}
         synchronous_mode = 0;
      otherwise
         warning (['option <', varargin{k}, '> ignored']);
      end
   elseif isa(varargin{k}, 'double')
      choice(varargin{k}) = 1;
   end
end   
return
