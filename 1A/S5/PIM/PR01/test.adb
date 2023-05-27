with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Integer_Text_IO;   use Ada.Integer_Text_IO;
with Ada.Calendar;          use Ada.Calendar;

procedure test is
	temps :Duration; --temps
	n: float;
begin
	temps := Duration(9.0);
	n:=float'Value(temps);
	Put(n);

end test;

