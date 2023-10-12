program untitled;

uses sysutils;
var i : integer;
	f1,f2 : text;
	s : string;
	c : char;
	

function strp_to_strv(s : string) : string;
var i : integer;
	coord : string;
begin
			i:=1;
			coord:='';
			c:=s[i];
				repeat
					coord := coord+c;
					i:=i+1;
					c:=s[i];
					
				until (c='.')or(i=length(s)+1);
			if not (i=length(s)+1) then
			begin
			coord := coord+',';
			i:=i+1;
			c:=s[i];
			
				repeat
					coord := coord+c;
					i:=i+1;
					c:=s[i];
				until i=length(s)+1;
			end;
		strp_to_strv:= coord;		
end;
	
	
BEGIN

	assign(f1,'tri.txt');
	assign(f2,'tri2.txt');
	
	reset(f1);
	rewrite(f2);
	
	repeat
		s:='';
		readln(f1,s);
		if not (s='NA') then writeln(f2,strp_to_strv(s))
		else writeln(f2, 3);
	until eof(f1);
	
	close(f1);
	close(f2);
END.

