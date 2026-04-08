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
-- Created: 20250929
-- Last Edited: 20260407


with Ada.Text_IO; use Ada.Text_IO;
with Ada.Directories;

procedure csvio is

	File		: File_Type; -- defines the csv file as a file type
	Line		: String (1 .. 200);  -- preallocates the line for reading each value
	Last_Line	: Natural := 0; -- defines the last line for checking if loop is rerun
	Line_Count	: Natural := 0; -- defines the number of lines
	File_Input	: String (1 .. 42); -- preallocates the file path string (CHANGE LAST NUMBER IF FILE PATH CHANGES)

	function Count_Lines (File_Name : String) return Natural is
		Temp_File	: File_Type; -- defines the temp file for reading
		Count		: Natural := 0;	 -- sets the count to 0
	
	begin
		Open (Temp_File, In_File, File_Name); -- opens the csv file 
		while not End_Of_File (Temp_File) loop -- runs while not last point in csv
			declare
				Dummy	: String (1 .. 200); -- preallocates the value string for printing the csv values
				Len		: Natural; -- preallocates the length of the value string
			begin
				Get_Line (Temp_File, Dummy, Len); -- gets the line from the csv
				Count	:= Count + 1; -- increases the count
			end;
		end loop;
		Close (Temp_File); -- closes the temp file
		return Count; -- returns the number of values in the csv file
	end Count_Lines;	 

	function Stop_Signal_Received return Boolean is -- setup to define when to exit the program
	begin
		return Ada.Directories.Exists ("stop.txt"); -- returns as true if stop.txt exists
	exception
		when others => 
			return False; -- returns as false otherwise
	end Stop_Signal_Received;
	
	
	
	Temp_CSV	: File_Type; -- defines the temp file for sending the csv data to ctlr
	
begin
	
	if Ada.Directories.Exists ("temp.txt") then
		Ada.Directories.Delete_File ("temp.txt"); -- deletes any previous temp files
	end if;
	
	File_Input := "D:/CardioSync/front-end/Data/ufmoutput.csv"; -- defines the file path
	Put_Line ("Reading file: " & File_Input); -- outputs the file path for verification
	
	Create (Temp_CSV, Out_File, "temp.txt"); -- creates the temp file
	
	loop
		
		exit when Stop_Signal_Received; -- exits if stop.txt exists
		
		Line_Count := Count_Lines (File_Input); -- counts the number of lines in the csv file
		
		if Line_Count > Last_Line then -- checks if the number of lines is greater than the last line read (if program is rerun on same csv file)
			Open (File, In_File, File_Input); -- opens csv file
			
			for I in 1 .. Last_Line loop -- iterates through all values in the file
				declare
					Dummy	: String (1 .. 200); -- defines the dummy string to be filled by each value in the file
					Len		: Natural; -- defines the length of each value
				begin
					Get_Line (File, Dummy, Len); -- gets the line for each line in the file and preallocates a space for it
				end;
			end loop;
			
			for I in Last_Line + 1 .. Line_Count loop -- iterates through the entire csv file
				declare
					Len	: Natural; -- defines the length of each value
				begin
					Get_Line (File, Line, Len); -- gets the line from the csv file
					Put_Line (Temp_CSV, Line (1 .. Len)); -- writes it to the temp file for reading by ctlr
				end;
			end loop;
			
			Close (Temp_CSV); -- closes the temp file
			Close (File); -- closes the csv file
			Last_Line := Line_Count; -- sets the last line (in case program is rerun on same csv file)
		end if;
		
		delay 0.2;
	end loop;
end csvio;

