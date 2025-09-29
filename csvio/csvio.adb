with Ada.Text_IO; use Ada.Text_IO;

procedure csvio is

	File		: File_Type;
	Line		: String (1 .. 200);
	Last_Line	: Natural := 0;
	Line_Count	: Natural := 0;

	function Count_Lines (File_Name : String) return Natural is
		Temp_File	: File_Type;
		Count		: Natural := 0;
		
	begin
		Open (Temp_File, In_File, File_Name);
		while not End_Of_File (Temp_File) loop
			declare
				Dummy	: String (1 .. 200);
				Len		: Natural;
			begin
				Get_Line (Temp_File, Dummy, Len);
				Count	:= Count + 1;
			end;
		end loop;
		Close (Temp_File);
		return Count;
	end Count_Lines;	

begin

	Put_Line ("Reading file: test.csv");
	
	loop
	
		Line_Count := Count_Lines ("C:\Users\bbouchard2023\Downloads\test.csv");
		
		if Line_Count > Last_Line then
			Open (File, In_File, "C:\Users\bbouchard2023\Downloads\test.csv");
			
			for I in 1 .. Last_Line loop
				declare
					Dummy	: String (1 .. 200);
					Len		: Natural;
				begin
					Get_Line (File, Dummy, Len);
				end;
			end loop;
			
			for I in Last_Line + 1 .. Line_Count loop
				declare
					Len	: Natural;
				begin
					Get_Line (File, Line, Len);
					Put_Line (Line (1 .. Len));
				end;
			end loop;
			
			Close (File);
			Last_Line := Line_Count;
		end if;
		
		delay 0.2;
	end loop;
end csvio;

