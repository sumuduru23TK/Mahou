function new_position = moveMotorFs(handles,motor_index,desired_position, speed, move_relative, move_async)
% put the code to move motors here. The desired position and new position
% are in units of fs. The command should return a number indicating where
% it got to, which could be different from the command (due to hitting a
% limit switch, etc)

global PI_1;
%dummy code
%pause(0.1);

if move_relative
  pos = getMotorPos(motor_index);
  desired_position = (pos-PI_1.center)*PI_1.factor+desired_position;
  desired_position = getMotorPos(1)+desired_position;
end

% Convert fs to mm.
new_position = desired_position/PI_1.factor + PI_1.center;

if new_position<PI_1.minimum
  new_position = PI_1.minimum;
elseif new_position>PI_1.maximum
  new_position = PI_1.maximum;
end


%% move to an absolute position
ratio = speed/PI_1.factor;
sendPIMotorCommand(1, sprintf('VEL 1 %f', speed/PI_1.factor), 0);
sendPIMotorCommand(1, sprintf('MOV 1 %f', new_position), 0);

%% Wait until stage reaches target
%val = queryMotorNoTerminator(PI_1.object, char(5));
%while val~=0
%  val = queryMotorNoTerminator(PI_1.object, char(5));
%end
if move_async==0
  while 1==1
    status = sendPIMotorCommand(1, 'SRG? 1 1', 1);
    num = uint16(hex2dec(status(7:end-1)));
    if bitand(num, hex2dec('A000'))==hex2dec('8000')
      break;
    else
      pause(0.1);
    end
  end

%% update the gui
  h = eval(sprintf('handles.edtMotor%i',1));
  pos = getMotorPos(motor_index);
  set(h, 'String', num2str((pos-PI_1.center)*PI_1.factor));
end
