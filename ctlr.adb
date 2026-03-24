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

	
	
	
	
	subtype Message is Stream_Element_Array (1 .. 11);
	
	Enquiry			: constant Stream_Element_Array := ( -- Sends an enquiry (checks if the pump is connected)
		1 => 16#02#, -- STX
		2 => 16#05#, -- ENQ
		3 => 16#0D# -- CR
	);
	
	
	Numeration   	: constant Stream_Element_Array  := ( -- Sets the pump's number (P01)
		1 => 16#02#, -- STX
		2 => 16#50#, -- P
		3 => 16#30#, -- 0
		4 => 16#31#, -- 1
		5 => 16#0D# -- CR
	);
	
	ControlInput   	: constant Stream_Element_Array  := ( -- Sets control parameters
		1 => 16#02#, -- STX
		2 => 16#50#, -- P
		3 => 16#30#, -- 0
		4 => 16#31#, -- 1
		5 => 16#53#, -- S
		6 => 16#2B#, -- +
		7 => 16#30#, -- 0
		8 => 16#31#, -- 1
		9 => 16#30#, -- 0
		10 => 16#30#, -- 0
		11 => 16#2E#, -- .
		12 => 16#30#, -- 0
		13 => 16#56#, -- V
		14 => 16#33#, -- 3
		15 => 16#30#, -- 0
		16 => 16#30#, -- 0
		17 => 16#2E#, -- .
		18 => 16#30#, -- 0
		19 => 16#47#, -- G
		20 => 16#0D# -- CR
	);
	
	StatusCheck		: constant Stream_Element_Array := ( -- Checks the pump's status after running controls
		1 => 16#02#, -- STX
		2 => 16#50#, -- P
		3 => 16#30#, -- 0
		4 => 16#31#, -- 1
		5 => 16#49#, -- I
		6 => 16#0D# -- CR
	);
	
	StopSignal		: constant Stream_Element_Array := ( -- Tells the pump to stop
		1 => 16#02#, -- STX
		2 => 16#50#, -- P
		3 => 16#30#, -- 0
		4 => 16#31#, -- 1
		5 => 16#48#, -- H
		6 => 16#0D# -- CR
	);
	
	Buffer	: Message; -- Sets up the buffer for reading the StatusCheck
	Last	: Stream_Element_Offset; -- Sets the endpoint for the Buffer

	S_Port	: constant Natural := 1; -- defines the serial port name ("COM<S_Port>") 

begin


	declare
	   Port_Name : constant Serial_Communications.Port_Name :=
					 Serial_Communications.Name (S_Port);
	   Port      : Serial_Communications.Serial_Port;

	begin
		Serial_Communications.Open -- Opens the serial port
		 (Port => Port,
		  Name => Port_Name);

		Serial_Communications.Set -- Sets the details for the serial port
		 (Port      => Port, 
		  Rate      => Serial_Communications.B4800,
		  Bits      => Serial_Communications.CS7,
		  Stop_Bits => Serial_Communications.One,
		  Parity    => Serial_Communications.Odd);

		Serial_Communications.Write -- Sends the inquiry
		 (Port   => Port,
		  Buffer => Enquiry);
		  
		  delay 0.1;
		  
		Serial_Communications.Write -- Sets the pump's number
		 (Port   => Port,
		  Buffer => Numeration);

		  delay 0.1;
		  
		Serial_Communications.Write -- Sets the control input (RPM, # revs, etc)
		 (Port   => Port,
		  Buffer => ControlInput);

		  delay 0.1;
		  
		Serial_Communications.Write -- Checks the pump's status
		 (Port   => Port,
		  Buffer => StatusCheck);
		  
		  delay 0.1;

		Serial_Communications.Read -- Reads the pump's response to the StatusCheck
		(Port => Port,
		 Buffer => Buffer,
		 Last => Last);
		
		for I in 1 .. Last loop
			Put (Stream_Element'Image(Buffer(I))); -- Prints the output from Read into the cmd prompt
			New_Line;
		end	loop;
		
		delay 5.0; -- Length the pump runs
		
		Serial_Communications.Write -- Sends the pump the stop signal
		 (Port   => Port,
		  Buffer => StopSignal);

		delay 1.0;
		
		Serial_Communications.Close -- Closes the serial port
		 (Port => Port);
	end;
end ctlr;
