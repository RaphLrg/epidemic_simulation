program untitled;
uses sysutils,crt;
var fic1,fic2,f : text;
	c       : char;
	s,num,nom,taille,densite,x,y,dpt,D : string;
	i,max ,p    : integer;
	total,n,seuil,min_n,max_n   : longint;
	max_x,min_x,max_y,min_y:real;
	test : boolean;
	temps0,tempsf		 : TSystemTime;
	

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
function diffTemps(temps2, temps1 : TSystemTime {Temps1 - Temps2}):longint;

begin
	diffTemps :=  (temps2.second - temps1.second) + 60*(temps2.minute - temps1.minute) + 3600*(temps2.hour - temps1.hour) + 3600*24*(temps2.day - temps1.day); //  + 3600*1000*24*30*(temps2.month - temps1.month) + 3600*1000*24*12(temps2.year - temps1.year)
end;
	
BEGIN
DateTimeToSystemTime(Now,temps0);
if not DirectoryExists('donnes_triees') then 
		CreateDir('donnes_triees');
assign(f,'donnes_triees\noms.txt');
assign(fic1,'base.txt');
rewrite(f);
cursoroff;
for p:=1 to (95+20) do
if not(p=20) then
begin

				//affichage
		gotoxy(10,10);
		writeln('       ');
		gotoxy(10,10);
		writeln(100*p/(95+20) :3:2,' %');
		
		
		
		
if p<=95 then
	begin
	if p<10 then d := '0'+inttostr(p)
	else d := inttostr(p)
	end
else seuil:=5000*(p-95);
reset(fic1);
max_x := 0;
max_y := 0;
min_x := 1000;
min_y := 50000;
min_n := 200000;
max_n := 0;
repeat
readln(fic1,c);
until (c='I');//or(eof(fic1));

n:=0;
total := 0;
repeat
begin				//debut de ligne
read(fic1,c);						//lecture du ( ou du I de INSERT
if (c='(') then 					//si on a (
	begin
		begin								//lecture du 1 er chiffre
				s:='';						//initialise s
				read(fic1,c);				//lecture du 1er chiffre
					repeat
					s:=s+c;					//on ajoute le chiffre a s
					read(fic1,c);			//on lit le chiffre suivant
					until ( c=',' );		//on sort au ,
				//write(fic2,s);
				num:=s;
				//writeln(s);	
			end;
			
			begin								//lecture jusqu'au ' du nom de ville
			i:=0;
			repeat
				repeat
					read(fic1,c);
				until c='''';
				i:=i+1;
			until i=1;
			end;
			begin								//lecture du departement
				s:='';						//initialise s
				read(fic1,c);				//lecture du premier caractere
					repeat
					s:=s+c;					//on ajoute le caractere a s
					read(fic1,c);			//on lit le caractere suivant suivant
					until ( c='''' );		//on sort au '
				//write(fic2,s);	
				dpt:=s;
			end;
			
			begin								//lecture jusqu'au ' du nom de ville
			i:=0;
			repeat
				repeat
					read(fic1,c);
				until c='''';
				i:=i+1;
			until i=1;
			end;
		begin								//lecture du nom de ville
			s:='';						//initialise s
			read(fic1,c);				//lecture du premier caractere
				repeat
				s:=s+c;					//on ajoute le caractere a s
				read(fic1,c);			//on lit le caractere suivant suivant
				until ( c='''' );		//on sort au '
			//write(fic2,s);	
			nom:=s;
		end;
	
		begin								//lecture jusqu'au , de la population de 2010
		i:=0;
		repeat
			repeat
				read(fic1,c);
			until c=',';
			i:=i+1;
		until i=12;
		end;
		begin								
			s:='';						//initialise s
			read(fic1,c);				//lecture du premier caractere
				repeat
				s:=s+c;					//on ajoute le caractere a s
				read(fic1,c);			//on lit le caractere suivant suivant
				until ( c=',' );		//on sort au '
			//write(fic2,s);
			taille:=s;		
		end;
		
		begin								//lecture jusqu'au , de la densité de population de 2010
		i:=0;
		repeat
			repeat
				read(fic1,c);
			until c=',';
			i:=i+1;
		until i=2;
		end;
		begin								
			s:='';						//initialise s
			read(fic1,c);				//lecture du premier caractere
				repeat
				s:=s+c;					//on ajoute le caractere a s
				read(fic1,c);			//on lit le caractere suivant suivant
				until ( c=',' );		//on sort au '
			//write(fic2,s);	
			densite:=s;		
		end;	

		begin								//lecture jusqu'au , de la longitude
		i:=0;
		repeat
			repeat
				read(fic1,c);
			until c=',';
			i:=i+1;
		until i=1;
		end;
				
		//read(fic1,c);		//on lit l'espace pour ne pas le garder
		begin								//lecture de la longitude (x)
			s:='';						//initialise s
			read(fic1,c);				//lecture du premier caractere
				repeat
				s:=s+c;					//on ajoute le caractere a s
				read(fic1,c);			//on lit le caractere suivant suivant
				until ( c=',' );		//on sort au '
				
					//conversion de degrés en x,y
						//conversion de 150.152 en 150,152

			//write(fic2,FloatToStr(StrToFloat(strp_to_strv(s))/360*6371));	
			x:=	s;
		end;
		
		read(fic1,c);		//on lit l'espace pour ne pas le garder
		begin								//lecture de la latitude (y)
			s:='';						//initialise s
			read(fic1,c);				//lecture du premier caractere
				repeat
				s:=s+c;					//on ajoute le caractere a s
				read(fic1,c);			//on lit le caractere suivant suivant
				until ( c=',' );		//on sort au '
			//write(fic2,FloatToStr(StrToFloat(strp_to_strv(s))/360*6371));
			//strp_to_strv(s));//
			y:=s;
		end;
		x:=FloatToStr(6371*StrToFloat(strp_to_strv(x))*2*pi*cos(StrToFloat(strp_to_strv(y))*2*pi/360)/360);
		y:=FloatToStr(6371*StrToFloat(strp_to_strv(y))*2*pi/360);
	
	if ((p<=95)and(dpt=d))or((p>95)and(strToInt(taille)>=seuil)) then 		//retour a la ligne du fichier si ecriture
	begin
	n:=n+1;

	if strtofloat(x)<min_x then min_x := strtofloat(x)
	else if strtofloat(x)>max_x then max_x := strtofloat(x);
	if strtofloat(y)<min_y then min_y := strtofloat(y)
	else if strtofloat(y)>max_y then max_y := strtofloat(y);
	if      strtoint(taille)<min_n then min_n := strtoint(taille)
	else if strtoint(taille)>max_n then max_n := strtoint(taille);
	end;
	
	
	end;
		
	readln(fic1);		//retout a la ligne de fic1
end;
until strtoint(num)=36208;//36568;

if p<=95 then 
		begin
		assign(fic2,'donnes_triees\departement-'+d+'.txt');
		writeln(f,'departement-'+d)
		end
else 
		begin
		assign(fic2,'donnes_triees\france_s_'+inttostr(seuil)+'_n_'+Inttostr(n)+'.txt');
		writeln(f,'france_s_'+inttostr(seuil)+'_n_'+Inttostr(n));
		end;

rewrite(fic2);

reset(fic1);
writeln(fic2,n);
writeln(fic2,min_x:5:5);
writeln(fic2,max_x:5:5);
writeln(fic2,min_y:5:5);
writeln(fic2,max_y:5:5);
writeln(fic2,min_n);
writeln(fic2,max_n);
n:=0;
total := 0;

repeat
readln(fic1,c);
until (c='I');//or(eof(fic1));


repeat
begin				//debut de ligne
read(fic1,c);						//lecture du ( ou du I de INSERT
if (c='(') then 					//si on a (
	begin
		begin								//lecture du 1 er chiffre
				s:='';						//initialise s
				read(fic1,c);				//lecture du 1er chiffre
					repeat
					s:=s+c;					//on ajoute le chiffre a s
					read(fic1,c);			//on lit le chiffre suivant
					until ( c=',' );		//on sort au ,
				//write(fic2,s);
				num:=s;
				//writeln(s);	
			end;
			
			begin								//lecture jusqu'au ' du nom de ville
			i:=0;
			repeat
				repeat
					read(fic1,c);
				until c='''';
				i:=i+1;
			until i=1;
			end;
			begin								//lecture du departement
				s:='';						//initialise s
				read(fic1,c);				//lecture du premier caractere
					repeat
					s:=s+c;					//on ajoute le caractere a s
					read(fic1,c);			//on lit le caractere suivant suivant
					until ( c='''' );		//on sort au '
				//write(fic2,s);	
				dpt:=s;
			end;
			
			begin								//lecture jusqu'au ' du nom de ville
			i:=0;
			repeat
				repeat
					read(fic1,c);
				until c='''';
				i:=i+1;
			until i=1;
			end;
		begin								//lecture du nom de ville
			s:='';						//initialise s
			read(fic1,c);				//lecture du premier caractere
				repeat
				s:=s+c;					//on ajoute le caractere a s
				read(fic1,c);			//on lit le caractere suivant suivant
				until ( c='''' );		//on sort au '
			//write(fic2,s);	
			nom:=s;
		end;
	
		begin								//lecture jusqu'au , de la population de 2010
		i:=0;
		repeat
			repeat
				read(fic1,c);
			until c=',';
			i:=i+1;
		until i=12;
		end;
		read(fic1,c);
		begin								
			s:='';						//initialise s
			read(fic1,c);				//lecture du premier caractere
				repeat
				s:=s+c;					//on ajoute le caractere a s
				read(fic1,c);			//on lit le caractere suivant suivant
				until ( c=',' );		//on sort au '
			//write(fic2,s);
			taille:=s;		
		end;
		
		begin								//lecture jusqu'au , de la densité de population de 2010
		i:=0;
		repeat
			repeat
				read(fic1,c);
			until c=',';
			i:=i+1;
		until i=2;
		end;
		read(fic1,c);
		begin								
			s:='';						//initialise s
			read(fic1,c);				//lecture du premier caractere
				repeat
				s:=s+c;					//on ajoute le caractere a s
				read(fic1,c);			//on lit le caractere suivant suivant
				until ( c=',' );		//on sort au '
			//write(fic2,s);	
			densite:=s;		
		end;	

		begin								//lecture jusqu'au , de la longitude
		i:=0;
		repeat
			repeat
				read(fic1,c);
			until c=',';
			i:=i+1;
		until i=1;
		end;
				
		//read(fic1,c);		//on lit l'espace pour ne pas le garder
		begin								//lecture de la longitude (x)
			s:='';						//initialise s
			read(fic1,c);				//lecture du premier caractere
				repeat
				s:=s+c;					//on ajoute le caractere a s
				read(fic1,c);			//on lit le caractere suivant suivant
				until ( c=',' );		//on sort au '
				
					//conversion de degrés en x,y
						//conversion de 150.152 en 150,152

			//write(fic2,FloatToStr(StrToFloat(strp_to_strv(s))/360*6371));	
			x:=	s;
		end;
		
		read(fic1,c);		//on lit l'espace pour ne pas le garder
		begin								//lecture de la latitude (y)
			s:='';						//initialise s
			read(fic1,c);				//lecture du premier caractere
				repeat
				s:=s+c;					//on ajoute le caractere a s
				read(fic1,c);			//on lit le caractere suivant suivant
				until ( c=',' );		//on sort au '
			//write(fic2,FloatToStr(StrToFloat(strp_to_strv(s))/360*6371));
			//strp_to_strv(s));//
			y:=s;
		end;
		x:=FloatToStr(6371*StrToFloat(strp_to_strv(x))*2*pi*cos(StrToFloat(strp_to_strv(y))*2*pi/360)/360);
		y:=FloatToStr(6371*StrToFloat(strp_to_strv(y))*2*pi/360);
	
	if ((p<=95)and(dpt=d))or((p>95)and(strToInt(taille)>=seuil)) then 		//retour a la ligne du fichier si ecriture
	begin
	n:=n+1;
	total := total + strtoint(taille);
	writeln(fic2,inttostr(n)+';'+nom+';'+taille+';'+densite+';'+x+';'+y+';');
	end;
	
	
	end;
		
	readln(fic1);		//retout a la ligne de fic1
end;
until strtoint(num)=36208;//36568;
close(fic2);
end;

close(f);
close(fic1);


DateTimeToSystemTime(Now,tempsf);

gotoxy(10,10);
writeln('       ');
gotoxy(10,10);
writeln('Exporte en ',diffTemps(tempsf,temps0),' sec');
delay(2000);
END.

