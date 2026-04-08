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
-- Last Edited: 20260407
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Streams;
with GNAT.Serial_Communications;
with Ada.Command_Line;
with GNAT.OS_Lib;
with Ada.Directories;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

procedure ctlr is
	use Ada.Streams;
	use GNAT;
	
	Full_Data	: Unbounded_String := Null_Unbounded_String; -- Used to store the whole .csv output from the ultrasound flow meter output for use in the PID
	
	arg1	: constant String := Ada.Command_Line.Argument(1); -- Takes the first argument from the command line when executed (RPM)
	RPM 	: Stream_Element_Array (1 .. arg1'Length);	-- Defines the stream element array for the RPM to be input into ControlInput
	
	EndPrompt		: String (1 .. 3); -- preallocates the end prompt
	EndPromptLength : Natural; -- defines the length of the end prompt as a number

	subtype Message is Stream_Element_Array (1 .. 11); -- Defines a stream element array subtype for reading the buffer in the Serial_Communications.Read call
	
	
	
	Buffer	: Message; -- Sets up the buffer for reading the StatusCheck
	Last	: Stream_Element_Offset; -- Sets the endpoint for the Buffer

	S_Port	: constant Natural := 1; -- defines the serial port name ("COM<S_Port>") 
	Temp_File	: constant String := "temp.txt";
	 
	 Stop	: Boolean := False; -- defines the stop call inside the script as a boolean (false)
	 pragma Atomic (Stop); -- defines the pragma for use inside the task
	  
	 task CSV_Task; -- predefines the task name
	 task body CSV_Task is	-- defines the task
		Exit_Code	: Integer; -- preallocates the exit code for the start of the csvio.exe spawn
		Args		: GNAT.OS_Lib.Argument_List (1 .. 0); -- defines an empty list for input arguments for csvio.exe
		Last_Line	: Natural := 0; -- defines the last line in the temp file for reading the .csv from the flow meter
	 begin
		
	  
		Exit_Code := GNAT.OS_Lib.Spawn (Program_Name => "D:/CardioSync/control-algorithm/test_programs/csvio/csvio.exe", Args => Args); -- starts csvio.exe
		
		loop
			exit when Stop; -- defines an exit from the loop when Stop = True (when user interrupts)
			
			if Ada.Directories.Exists (Temp_File) then -- checks if temp csv file exists
				declare
					CSV_File	: File_Type; -- defines the temp file as a file type
					CSV_Line	: String (1 .. 200); -- preallocates each line 
					CSV_Len		: Natural; -- predefines the length of each line as a number
					Curr_Line	: Natural := 0; -- defines the current line, starting at 0
					LF			: constant String := ASCII.LF & ""; -- creates a string for the "\n" at the end of each line in Full_Data
				begin
					Open (CSV_File, In_File, Temp_File); -- opens the temp file
					
					while not End_Of_File (CSV_File) loop -- checks if the current pointer is at the end of the temp csv file
						Get_Line (CSV_File, CSV_Line, CSV_Len); -- gets the line from the temp csv
						Curr_Line := Curr_Line + 1; -- increases the current line to get the next line
						if Curr_Line > Last_Line then -- checks if the current line is greater than the last line in the file (if read from same file more than once)
							Full_Data := Full_Data & To_Unbounded_String (CSV_Line (1 .. CSV_Len)) & To_Unbounded_String (LF); -- concatenates Full_Data and the current line (\n at the end)
							Put_Line (To_String (Full_Data)); -- prints the entire Full_Data variable
						end if;
					end loop;
					
					Close (CSV_File); -- closes the temp file
					Last_Line := Curr_Line; -- defines the last line as the current line (if same file is read more than once)
				end;
			end if;
			
		end loop;
		
		if Exit_Code /= 0 then -- checks if there's an error running csvio.exe
			Put_Line ("Unknown Error!");
		end if;
		
	
	
	  end CSV_Task;
	  
	  StopFile	: File_Type; -- defines the type for the file used to stop csvio.exe
	  
	  
	
begin
	
	for I in arg1'Range loop
		RPM (Stream_Element_Offset(I)) := Stream_Element(Character'Pos(arg1(I))); -- Transforms String type from the first argument to Stream_Element type
	end loop;
	
	
	declare
		Port_Name 		: constant Serial_Communications.Port_Name := Serial_Communications.Name (S_Port); -- Defines the serial port name
		Port      		: Serial_Communications.Serial_Port; -- Defines Serial_Port from the Serial_Communications package as "Port"
		
		ControlInput   	: constant Stream_Element_Array  := ( -- Sets control parameters
			1 => 16#02#, -- STX (start text)
			2 => 16#50#, -- P
			3 => 16#30#, -- 0
			4 => 16#31#, -- 1
			5 => 16#53#, -- S (speed)
			6 => 16#2B#, -- + (clockwise rotation)
			7 => 16#30#, -- 0
			8 => RPM (1), -- input digit 1
			9 => RPM (2), -- input digit 2
			10 => RPM (3), -- input digit 3
			11 => RPM (4), -- input decimal
			12 => RPM (5), -- input digit 4
			13 => 16#47#, -- G
			14 => 16#30#, -- 0
			15 => 16#0D# -- CR
		);
		
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
				
		Put ("Type 'end' to end program: ");
		Get_Line (EndPrompt, EndPromptLength);
		
		if EndPrompt = "end" then
				 
				 Create (StopFile, Out_File, "stop.txt"); -- creates the stop file that csvio.exe checks for to end
				
				 Close (StopFile); -- closes the stop file
				
				 Stop := True; -- defines Stop as True to end the loop that checks the temp csv file
				
				 Serial_Communications.Write -- Sends the pump the stop signal
				 (Port   => Port,
				  Buffer => StopSignal);
					
		end if;
		
		delay 1.0;
			
		Serial_Communications.Close -- Closes the serial port
			(Port => Port);
		
		Ada.Directories.Delete_File ("stop.txt");
		
	end;
end ctlr;
