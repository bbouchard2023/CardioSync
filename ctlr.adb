--      ___           ___           ___           ___                       ___           ___           ___           ___           ___
--     /\  \         /\  \         /\  \         /\  \          ___        /\  \         /\  \         |\__\         /\__\         /\  \
--    /::\  \       /::\  \       /::\  \       /::\  \        /\  \      /::\  \       /::\  \        |:|  |       /::|  |       /::\  \
--   /:/\:\  \     /:/\:\  \     /:/\:\  \     /:/\:\  \       \:\  \    /:/\:\  \     /:/\ \  \       |:|  |      /:|:|  |      /:/\:\  \
--  /:/  \:\  \   /::\~\:\  \   /::\~\:\  \   /:/  \:\__\      /::\__\  /:/  \:\  \   _\:\~\ \  \      |:|__|__   /:/|:|  |__   /:/  \:\  \
-- /:/__/ \:\__\ /:/\:\ \:\__\ /:/\:\ \:\__\ /:/__/ \:|__|  __/:/\/__/ /:/__/ \:\__\ /\ \:\ \ \__\     /::::\__\ /:/ |:| /\__\ /:/__/ \:\__\
-- \:\  \  \/__/ \/__\:\/:/  / \/_|::\/:/  / \:\  \ /:/  / /\/:/  /    \:\  \ /:/  / \:\ \:\ \/__/    /:/~~/~    \/__|:|/:/  / \:\  \  \/__/
--  \:\  \            \::/  /     |:|::/  /   \:\  /:/  /  \::/__/      \:\  /:/  /   \:\ \:\__\     /:/  /          |:/:/  /   \:\  \
--   \:\  \           /:/  /      |:|\/__/     \:\/:/  /    \:\__\       \:\/:/  /     \:\/:/  /     \/__/           |::/  /     \:\  \
--    \:\__\         /:/  /       |:|  |        \::/__/      \/__/        \::/  /       \::/  /                      /:/  /       \:\__\
--     \/__/         \/__/         \|__|         ~~                        \/__/         \/__/                       \/__/         \/__/
--
--
-- Created: 20260319
-- Last Edited: 20260324
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Streams;
with GNAT.Serial_Communications;

procedure ctlr is
	use Ada.Streams;
	use GNAT;

	
	
	
	
	subtype Message is Stream_Element_Array (1 .. 3);
	Data   	: constant Stream_Element_Array  := (
	1 => 16#02#,
	2 => 16#05#,
	3 => 16#13#
	);
	Buffer 	: Message;

	Last   : Stream_Element_Offset;

	S_Port : constant Natural := 1;

begin


	declare
	   Port_Name : constant Serial_Communications.Port_Name :=
					 Serial_Communications.Name (S_Port);
	   Port      : Serial_Communications.Serial_Port;

	begin
		Serial_Communications.Open
		 (Port => Port,
		  Name => Port_Name);

		Serial_Communications.Set
		 (Port      => Port,
		  Rate      => Serial_Communications.B4800,
		  Bits      => Serial_Communications.CS7,
		  Stop_Bits => Serial_Communications.One,
		  Parity    => Serial_Communications.Odd);


		Serial_Communications.Write
		 (Port   => Port,
		  Buffer => Data);

		  delay 0.1;

		Serial_Communications.Read
		(Port => Port,
		 Buffer => Buffer,
		 Last => Last);
		
		for I in 1 .. Last loop
			Put (Stream_Element'Image(Buffer(I)));
			New_Line;
		end	loop;

		Serial_Communications.Close
		 (Port => Port);
	end;
end ctlr;
