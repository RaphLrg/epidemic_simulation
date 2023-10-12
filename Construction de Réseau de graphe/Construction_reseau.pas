program untitled;
uses sysutils;


const 

				//modifier ici 
//#########################################################################################################
//#########################################################################################################


	  nb_classes = 3;			//nombre de classes de villes différentes
	  
	  ordre_h_id = 1;			//nombre de routes vers une villes de même classe
	  ordre_h_sup= 1;			//nombre de routes vers une villes de classe supérieure ou égale
	  
	  
//#########################################################################################################
//#########################################################################################################
	  
	  constanteN  = 1E-3;
	  d_min      =40; //km
		
type cases = record
	x,y         : real;
	voisin_meme : array[1..ordre_h_id ]of integer;
	voisin_sup  : array[1..ordre_h_sup ]of integer;
	nom         : string;
	dens 		: integer;
	taille      : longint;
	classe      : 1..20;
end;

type mon_tab = array[1..100000] of cases;

var fic1,fic2,fi	                   	: text;
	c                                	: char;
	s,mon_fichier						: string;
	i,n,p,couleur						: integer;
	max_x,max_y,min_x,min_y,x  			: real;
	min_n,max_n,k 						: longint;
	tab 								: mon_tab;
	tab_seuil							: array[0..20] of real;


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
function strv_to_strp(s : string) : string;
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
					
				until (c=',')or(i=length(s)+1);
			if not (i=length(s)+1) then
			begin
			coord := coord+'.';
			i:=i+1;
			c:=s[i];
			
				repeat
					coord := coord+c;
					i:=i+1;
					c:=s[i];
				until i=length(s)+1;
			end;
		strv_to_strp:= coord;		
end;

function f(t1,t2 : longint; d : real):qword;
begin
f:=round((constanteN*t1*t2)/sqr(d + d_min*exp(-d/d_min)));
if f<1 then f:=1;
{
writeln(f);
}
end;

procedure ville_ordre_n(var tab : mon_tab; n : integer);
var d : real;
    min_meme :  array[1..ordre_h_id ]of real;
    min_sup  :  array[1..ordre_h_sup]of real;
	i,j, p : integer;
	condition : boolean;
begin
for i:=1 to n do
	begin
    for p := 1 to ordre_h_id do 
		begin
		min_meme[p] := 1000;
		tab[i].voisin_meme[p] := 0;
		end;
	for p := 1 to ordre_h_sup do 
		begin
		min_sup[p] := 1000;
		tab[i].voisin_sup[p] := 0;
		end;
	

	
		for j :=1 to n do
		if (i<>j) then 
			begin
			d:=sqrt(sqr(tab[i].x-tab[j].x)+sqr(tab[i].y-tab[j].y)); 
			
			if tab[i].classe=tab[j].classe then
				for p := ordre_h_id downto 1 do
					if (d<min_meme[p]) then
							begin
									if (p<>ordre_h_id) then
										begin
										tab[i].voisin_meme[p+1] := tab[i].voisin_meme[p];
										min_meme[p+1] := min_meme[p];
										end;
											
									tab[i].voisin_meme[p] := j;
									min_meme[p]:=d;
							end;	
							
			
			condition := true;
			if (tab[i].classe<=tab[j].classe)and not(tab[i].classe=nb_classes) then 
				for p:= 1 to ordre_h_id do 
					if (j=tab[i].voisin_meme[p]) then condition := false ;
			
					
			if (tab[i].classe<=tab[j].classe)and not(tab[i].classe=nb_classes)and condition then
				for p := ordre_h_sup downto 1 do
					if (d<min_sup[p]) then
							begin
								//writeln(i,' : ',tab[i].classe,'     ',j,' : ',tab[j].classe);
									if (p<>ordre_h_sup) then
										begin
										tab[i].voisin_sup[p+1] := tab[i].voisin_sup[p];
										min_sup[p+1] := min_sup [p];
										end;
											
									tab[i].voisin_sup[p] := j;
									min_sup[p]:=d;
							end;
							
			end;	
		
end;


end;



function max(x,y : integer):integer;
begin
if x>y then max :=x
else max := y;
end;
function max(x,y : real):real;
begin
if x>y then max :=x
else max := y;
end;
function min(x,y : integer):integer;
begin
if x<y then min :=x
else min := y;
end;
function min(x,y : real):real;
begin
if x<y then min :=x
else min := y;
end;

procedure export_matrice(var tab : mon_tab; var n:integer);
var i,j,p,nb_route,a,b : integer;
	fic3 : text;
	matrice : array[1..3500,1..3500] of boolean;
	d : real;
begin
nb_route := 0;

for i := 1 to n do
	for j := 1 to n do 
		matrice[i,j] := false;
		
for i := 1 to n do
	for j := 1 to n do 
		if i<>j then
			begin
			a:=min(i,j);
			b:=max(i,j);
			for p := 1 to ordre_h_id do 
				if (not(matrice[a,b]))and(tab[i].voisin_meme[p]=j) then
					begin
					matrice[a,b] := true;
					nb_route:=nb_route + 1;
					end;
			for p := 1 to ordre_h_sup do 
				if (not(matrice[a,b]))and(tab[i].voisin_sup[p]=j) then
					begin
					matrice[a,b] := true;
					nb_route:=nb_route + 1;
					end;
			end;

//writeln(8);
assign(fic3,'export_latex_pascal\classes_'+inttostr(nb_classes)+'\id_'+ inttostr(ordre_h_id)+'\sup_'+ inttostr(ordre_h_sup)+'\'+mon_fichier+'\pascal_classe_'+inttostr(nb_classes)+'_id_'+ inttostr(ordre_h_id)+'_sup_'+ inttostr(ordre_h_sup)+'_'+mon_fichier+'.txt');
rewrite(fic3);

writeln(fic3,n);
writeln(fic3,nb_route);
writeln(fic3);
writeln(fic3);
writeln(fic3);

for i := 1 to n do
	for j := 1 to n do 
		if matrice[i,j] then 
			begin
			d:=sqrt(sqr(tab[i].x-tab[j].x)+sqr(tab[i].y-tab[j].y));
			//writeln(i,' et ',j,' => ',d:3:5);
			writeln(fic3,i,' ',j,' ',f(tab[i].taille,tab[j].taille,d));
			//writeln(i,'   ',j);
			couleur := trunc(5*ln(f(tab[i].taille,tab[j].taille,d)));
			if couleur>100 then couleur := 100;
			writeln(fic2,'		\draw[route,blue!',couleur,',-,>=latex,line width =',(0.05*ln(f(tab[i].taille,tab[j].taille,d))+0.01):2:2,'pt] (',i,') -- (',j,');  ');
			//writeln(i,' * ',j)
			end;
writeln(fic3);
writeln(fic3);
writeln(fic3);
for i := 1 to n do
	writeln(fic3,tab[i].taille,' 0 ',tab[i].dens,' ',tab[i].nom);
close(fic3);
end;


	
BEGIN
if not DirectoryExists('export_latex_pascal') then 
		CreateDir('export_latex_pascal');

assign(fi,'donnes_triees\noms.txt');
reset(fi);
repeat

readln(fi,mon_fichier);

writeln(mon_fichier);
if not DirectoryExists('export_latex_pascal\classes_'+inttostr(nb_classes)) then 
		CreateDir('export_latex_pascal\classes_'+inttostr(nb_classes));
		
if not DirectoryExists('export_latex_pascal\classes_'+inttostr(nb_classes)+'\id_'+ inttostr(ordre_h_id)) then 
		CreateDir('export_latex_pascal\classes_'+inttostr(nb_classes)+'\id_'+ inttostr(ordre_h_id));
		
if not DirectoryExists('export_latex_pascal\classes_'+inttostr(nb_classes)+'\id_'+ inttostr(ordre_h_id)+'\sup_'+ inttostr(ordre_h_sup)) then 
		CreateDir('export_latex_pascal\classes_'+inttostr(nb_classes)+'\id_'+ inttostr(ordre_h_id)+'\sup_'+ inttostr(ordre_h_sup));
		

//writeln(1);
if not DirectoryExists('export_latex_pascal\classes_'+inttostr(nb_classes)+'\id_'+ inttostr(ordre_h_id)+'\sup_'+ inttostr(ordre_h_sup)+'\'+mon_fichier) then 
			 CreateDir('export_latex_pascal\classes_'+inttostr(nb_classes)+'\id_'+ inttostr(ordre_h_id)+'\sup_'+ inttostr(ordre_h_sup)+'\'+mon_fichier);
//writeln(1);
assign(fic2,'export_latex_pascal\classes_'+inttostr(nb_classes)+'\id_'+ inttostr(ordre_h_id)+'\sup_'+ inttostr(ordre_h_sup)+'\'+mon_fichier+'\latex_classe_'+inttostr(nb_classes)+'_id_'+ inttostr(ordre_h_id)+'_sup_'+ inttostr(ordre_h_sup)+'_'+mon_fichier+'.txt');
assign(fic1,'donnes_triees\'+mon_fichier+'.txt');
//writeln(2);

begin
reset(fic1);
//				writeln(3);
rewrite(fic2);
//				writeln(4);
tab[1].x := 0;
tab[1].y := 0;
readln(fic1,n);
readln(fic1,min_x);
readln(fic1,max_x);
readln(fic1,min_y);
readln(fic1,max_y);
readln(fic1,min_n);
readln(fic1,max_n);
for i:=1 to n do
	begin
		repeat
		read(fic1,c);
		until c=';';
		
		s:='';				//lecture du nom
		read(fic1,c);
		repeat
			s:=s+c;
			read(fic1,c);
		until c=';';
		tab[i].nom:=s;
		
		s:='';				//lecture de la pop 2010
		read(fic1,c);
		repeat
			s:=s+c;
			read(fic1,c);
		until c=';';
		tab[i].taille:=strtoint(s);

		s:='';				//lecture de la densite 2010
		read(fic1,c);
		repeat
			s:=s+c;
			read(fic1,c);
		until c=';';
		tab[i].dens:=strtoint(s);

		s:='';				//lecture des coord x
		read(fic1,c);
		repeat
			s:=s+c;
			read(fic1,c);
		until c=';';
		tab[i].x:=strtofloat(s);

		s:='';				//lecture des coord y
		read(fic1,c);
		repeat
			s:=s+c;
			read(fic1,c);
		until c=';';
		tab[i].y:=strtofloat(s);

		readln(fic1);
	end;
//								writeln(10);
for i := 0 to nb_classes do 
	//tab_seuil[i] := min_n + (max_n-min_n)*i/nb_classes;		//linéaire
	tab_seuil[i] := exp(ln(min_n+1) + (ln(max_n)-ln(min_n+1))*i/nb_classes);    //logarithmique
	//tab_seuil[i] := sqr(sqrt(min_n) + (sqrt(max_n)-sqrt(min_n))*i/nb_classes);    //quadratique
//								writeln(11);
x:=max(max_x-min_x,max_y-min_y);
for k := 1 to n do
	begin
	i:=0;
	
{
	tab[k].x:= (tab[k].x-min_x)*15/x;
	tab[k].y:= (tab[k].y-min_y)*15/x;
}
	//writeln(fic2,tab[k].nom,' : ',tab[k].taille);
	repeat
		i:=i+1;
		if (tab[k].taille<=(tab_seuil[i]+0.1)) then tab[k].classe := i
	until tab[k].taille<=tab_seuil[i]+0.1;
	end;
for p := 1 to nb_classes do
for i := 1 to n do 	if (tab[i].classe=p)then writeln(fic2,'			\node[circle,fill={rgb,255:red,'+inttostr(trunc(tab[i].classe*50))+'; green,66; blue,128},scale=',0.25*tab[i].classe/nb_classes:3:2,'] ('+inttostr(i)+') at ('
								+strv_to_strp(floattostr((tab[i].x - min_x)*15 / x))+','+strv_to_strp(floattostr((tab[i].y - min_y) *15/x))+') {};%'+tab[i].nom);
	//writeln(fic2,'			\node[] ('+inttostr(i)+') at ('
	//+strv_to_strp(floattostr(tab[i].x))+','+strv_to_strp(floattostr(tab[i].y))+') {.};%'+tab[i].nom);
	
//								writeln(5);	
ville_ordre_n(tab,n);
//								writeln(6);	
export_matrice(tab,n);
//writeln('nombre : ',n);

for p := 1 to nb_classes do
for i := 1 to n do 	if (tab[i].classe=p)then writeln(fic2,'			\node[circle,fill={rgb,255:red,'+inttostr(trunc(tab[i].classe*50))+'; green,66; blue,128},scale=',0.25*tab[i].classe/nb_classes:3:2,'] ('+inttostr(i)+') at ('
								+strv_to_strp(floattostr((tab[i].x - min_x)*15 / x))+','+strv_to_strp(floattostr((tab[i].y - min_y) *15/x))+') {};%'+tab[i].nom);
	//writeln(fic2,'			\node[] ('+inttostr(i)+') at ('
	//+strv_to_strp(floattostr(tab[i].x))+','+strv_to_strp(floattostr(tab[i].y))+') {.};%'+tab[i].nom);
	
	
end;
close(fic1);
close(fic2);
until eof(fi);
close(fi);
{
end;
end;
end;
}
END.

