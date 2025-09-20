with Ada.Text_IO; use Ada.Text_IO;
procedure Main is
	procedure Nested is
	begin
	null;
	end Nested;
begin
	Put_Line ("Hello World!");
	Nested;
end Main;
