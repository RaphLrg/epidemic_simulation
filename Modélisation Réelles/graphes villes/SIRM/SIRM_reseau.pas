
//modele SIR avec un graphe en entrée

program vecteur;

uses sysutils,crt;

const Xmax           = 5;
	  ville_max      = 200;				// nombre max de ville
	  //Mmax           = 70;				// taille de plus grande matrice = max ( ville_max ; x_max )	  
	  
	  Intervalle     = 3000;			// nombre de subdivision de l'intervalle
	  Ti             = 0;
	  Tf             = 200;
	  
	  
	  //beta           =0.2;				//taux de transmission
	  lambda         =10;				//temps d'infection
	  mu			 =0.01;				//taux de mortalité
	  R0			 =3;
	  
	  //N0             =1000;				//population initiale
	  Gamma0		 =0.01;				//population initiale infectée
	  

	  
	  
type vec             = array[1..Xmax]      of Real;								//vecteur colonne de taille Xmax
     Matrice_totale  = array[1..ville_max,1..Xmax] of Real;       //matrice enregistrant toutes les positions des vecteurs de chaques villes
     laplacien       = array[1..ville_max,1..ville_max] of real;

	 //big_Matrice     = array[1..Mmax,1..Mmax] of real;
	 Les_voyageurs   = set of 1..Xmax;
	 tab_densite     = array[1..ville_max] of integer;

var  beta	: array[1..ville_max] of real;
//#################################################################################################################################
//#################################################################################################################################
function strv_to_strp(s : string) : string;
var i : integer;
	coord : string;
	c : char;
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
	//partie vecteurs

function somme_vec(X1,X2 : vec) : vec;					   						//somme de 2 vec
var i : integer;
begin
//writeln('balise6');
for i := 1 to Xmax do somme_vec[i] := X1[i] + X2[i];
end;



function Produit_vec(X : vec; k : real) : vec;									//produit d'un vec par un scalaire
var i : integer;
begin
		//	writeln('balise5');
for i := 1 to Xmax do Produit_vec[i] := k * X[i];
end;



//#################################################################################################################################
//#################################################################################################################################

	//partie graphes

Procedure chargement_Laplacien(var m0 : matrice_totale ; var l : laplacien; var routes, villes : integer;var densite : tab_densite);
var fichier : text;
	nom     : string;
	i,v1,v2 : integer;
	gamma,N0: real;
begin
	nom := 'graphe_pascal.txt';//essai1_62_villes
	assign(fichier, nom);
	reset(fichier);
	v1 := 1;
	v2 := 1;
	gamma := 1;
		readln(fichier,villes);
		readln(fichier,routes);
		
		readln(fichier);
		readln(fichier);
		readln(fichier);
		
		for i := 1 to routes do
			begin
			read  (fichier,v1);
			read  (fichier,v2);
			readln(fichier,gamma);
			
			l[v1,v1] := l[v1,v1] + gamma;
			l[v2,v2] := l[v2,v2] + gamma;
			l[v1,v2] := -gamma;
			l[v2,v1] := -gamma;
			end;
	
		readln(fichier);	
		readln(fichier);	
		readln(fichier);	
		
		for i := 1 to villes do													//  A MODIFIER POUR UN NOUVEAU SYSTEME
			begin	
			read  (fichier, N0);
			read  (fichier, Gamma);
			
			//writeln(i,' avant');
			readln  (fichier, densite[i]);
			//writeln(i,' apres');
			
			M0 [i,1] := (1-Gamma)*N0;									//Sain
			M0 [i,2] := Gamma * N0;    								//Infecte
			M0 [i,3] := 0;												//Remis
			M0 [i,4] := 0;												//Mort
			M0 [i,5] := N0;											//Pop totale
			
			
			
			end;
			
	close(fichier);
	for v1 := 1 to villes do
		for v2 := 1 to villes do
			begin
			//gotoxy(10*v1,2*v2);
			//write(l[v1,v2] :3:1);
			end;

end;



//#################################################################################################################################
//#################################################################################################################################
		//partie matrices
 
{
}

{
function PM (m1,m2 : big_matrice ; t1,t2,t3 : integer) : big_matrice;
var i,j,x : 1..Mmax;
begin
for i := 1 to Mmax do 
	for j := 1 to Mmax do 
		PM[i,j]:=0;				//initialisation
for i := 1 to t1 do 
	for j := 1 to t3 do
		for x := 1 to t2 do  PM[i,j]:= PM[i,j] + m1[i,x]*m2[x,j];
end;

function M_gamma(v:les_voyageurs) : big_matrice;
var i,j : 1..Mmax;
begin
for i := 1 to Mmax do 
	for j := 1 to Mmax do 
		if (i=j) and (i in v) then M_gamma[i,j]:=1
		else M_gamma[i,j]:=0					
end;

function M_1_N (M : Matrice_totale; n_n,n_ville : integer) : big_matrice;		//n est la position de N dans les equadiff
var i,j : 1..Mmax;
begin
for i := 1 to Mmax do 
	for j := 1 to Mmax do 
		if (i=j) and (i<=n_ville) then M_1_N[i,j]:=(1/ M[i,n_n])
		else M_1_N[i,j]:=0		
end;

function M_Y_tot (M : Matrice_totale; n_ville : integer) : big_matrice;		
var i,j : 1..Mmax;
begin

for i := 1 to xmax do 
	for j := 1 to n_ville do 
		 M_Y_tot[i,j]:=M[j,i]
	
end;

function Delta_x (delta : laplacien; n_ville, ville_x : integer) : big_matrice;		
var i,j : 1..Mmax;
begin
for i := 1 to Mmax do 
	for j := 1 to Mmax do 
		if (j=1)and(i<=n_ville) then Delta_x[i,1] :=delta[ville_x,i]
		else Delta_x[i,j] :=0		
end;

function Matrice_to_vec(M:big_matrice):vec;
var i : 1..xmax;
begin
for i:= 1 to xmax do Matrice_to_vec[i]:=M[i,1]
end;
}

{
procedure speciale(M:matrice_totale; delta : laplacien; v:les_voyageurs; ville_x,n_ville,n_n,t:integer;dt : real);
var i,j : integer;
	fic : text;
begin
export_matrice(M_gamma(v),'M1');
export_matrice(M_Y_tot(M,n_ville,t),'M2');
export_matrice(M_1_N(M,n_n,n_ville,t),'M3');
export_matrice(Delta_x(delta,n_ville,ville_x),'M4');
assign(fic,'test\M5.txt');
rewrite(fic);
for j := 1 to n_ville do
	begin
	for i := 1 to n_ville do
		write(fic,Delta[i,j]:2:0,' ');
	writeln(fic);
	end;
close(fic);
end;

}


function Y_ext(M:matrice_totale; delta : laplacien; v:les_voyageurs; ville_x,n_ville,n_n,t:integer;dt : real):vec;
var ligne,city : integer;
begin
for ligne := 1 to xmax do
	Y_ext[ligne]:=0;
	

for ligne := 1 to xmax do
	if (ligne in v) then
	
		for city := 1 to n_ville do
				begin
				Y_ext[ligne] := Y_ext[ligne] - dt * delta[city,ville_x] *  M[city,ligne] / M[city,n_n];
				//writeln('dt : ',dt:1:5,' ; laplacien : ', delta[city,ville_x] ,' ; case : ',  M[city,ligne] ,' ; ntotal : ', M[city,n_n]);
				end

{
for ligne := 1 to xmax do
	writeln(Y_ext[ligne]:2:6);
	writeln;
}

end;


//########################################################################################################################################
//########################################################################################################################################
	
		//equa diff
	
		
function F (ville : integer ; Y:vec) : vec;

begin
F[1] := - beta[ville] * Y[1] * Y[2] / Y[5];									
F[2] :=   beta[ville] * Y[1] * Y[2] / Y[5] - (1/lambda) * Y[2] - mu * Y[2];
F[3] :=   (1/lambda)  * Y[2];
F[4] :=   mu *          Y[2];
F[5] :=  -mu *	    	Y[2];
end;

function vec_M(ville : integer; M : matrice_totale) : vec;
var i : integer;
begin
for i := 1 to xmax do vec_M[i] := M[ville,i];
//writeln('balise1');
end;


procedure etapes_infinitesimale(x,ville_total : integer;dt : real; var M,M0: matrice_totale ; L : laplacien;n_n : integer; v : les_voyageurs);
var i , ville: integer;
	Y    : vec;
	tx  : real;
begin


for ville := 1 to ville_total do

	begin
			tx := x * dt + Ti;
			//writeln('balise0 ',ville);
			Y  := somme_vec( vec_M(ville,M0), produit_vec(        F(ville,somme_vec( vec_M(ville,M0), produit_vec(F(ville,vec_M(ville,M0)) ,dt/2)))           ,dt));
						
			Y := somme_vec(Y , Y_ext(M0,L,v,ville,ville_total,n_n,x,dt));							// somme des int et ext
			
			
			for i := 1 to xmax do M[ville,i] := Y[i];
	end;
end;

var dt ,dmin,dmax          : Real;
	M,M0            : matrice_totale;
	x,i,p,n_n,j	 : integer;		
	nom 		 : string;
	fichier		 : text;
	l            : laplacien;
	routes,villes: integer;
	voyageurs    : les_voyageurs;
	densite		 : tab_densite;

	temps0,tempsf		 : TSystemTime;
//########################################################################################################################################
//########################################################################################################################################

function diffTemps(temps2, temps1 : TSystemTime {Temps1 - Temps2}):longint;

begin
	diffTemps :=  (temps2.second - temps1.second) + 60*(temps2.minute - temps1.minute) + 3600*(temps2.hour - temps1.hour) + 3600*24*(temps2.day - temps1.day); //  + 3600*1000*24*30*(temps2.month - temps1.month) + 3600*1000*24*12(temps2.year - temps1.year)
end;


begin

DateTimeToSystemTime(Now,temps0);
//##########
//##########
voyageurs := [1,2,3];                       // mettre ici les gens qui voyagent
n_n       := 5; 							// place de N dans l'equadiff
//##########
//##########
writeln(1);
chargement_Laplacien(M0,l,routes,villes,densite);

dmax := 0;
dmin := 100000000;
for i := 1 to villes do
	begin
		 if densite[i]<dmin then dmin:= densite[i]
	else if densite[i]>dmax then dmax:= densite[i]
	end;




nom := 'export.txt';

assign(fichier,nom);
rewrite(fichier);
for i := 1 to villes do 
	//writeln(fichier,FloatToStrF(3*(0.5+((ln(densite[i])-ln(dmin))/(ln(dmax)-ln(dmin)))),ffFixed,4,10));
	beta[i] := R0*(0.5+((ln(densite[i])-ln(dmin))/(ln(dmax)-ln(dmin)))) / Lambda;
close(fichier);









writeln(2);
dt := (Tf-Ti)/Intervalle;
{
writeln(routes,' ',villes);
assign(fichier,'laplacien.txt');
rewrite(fichier);
for i := 1 to villes do
	begin
	for j := 1 to villes do 
		write(fichier,l[i,j]:4:0,' ');
	writeln(fichier);
	end;
close(fichier);
}

nom := 'export.txt';

assign(fichier,nom);
rewrite(fichier);
{
	for i := 0 to p do 
		begin
		write  (fichier,FloatToStrF(i*dt *(intervalle div p),   ffFixed,4,4) ,' ');
			for x := 1 to villes do
			for n_n := 1 to xmax do 
					write  (fichier,FloatToStrF(M[x,n_n,(intervalle div p)*i],ffFixed,4,10),' ');
		writeln(fichier);
}

write(fichier,'Temps ');
write(fichier,'Narbonne_S Narbonne_I Narbonne_R Narbonne_M Narbonne_N '); 
write(fichier,'Marseille_S Marseille_I Marseille_R Marseille_M Marseille_N ');
write(fichier,'Toulouse_S Toulouse_I Toulouse_R Toulouse_M Toulouse_N ');
write(fichier,'Chateauroux_S Chateauroux_I Chateauroux_R Chateauroux_M Chateauroux_N ');
write(fichier,'Perpignan_S Perpignan_I Perpignan_R Perpignan_M Perpignan_N ');
write(fichier,'Paris_S Paris_I Paris_R Paris_M Paris_N ');

p := 1000;
for x := 0 to Intervalle-1 do 
	begin
	etapes_infinitesimale(x,villes,dt,M,M0,L,n_n,voyageurs);
	if (x mod 10 = 0) then writeln(x);
	if (x mod (intervalle div p)) = 0 then 
		begin
			write  (fichier,strv_to_strp(FloatToStrF(x*dt,   ffFixed,4,4)) ,' ');
			for i in [14,97,40,18,113,50] do
			for n_n := 1 to xmax do 
					write  (fichier,strv_to_strp(FloatToStrF(M[i,n_n],ffFixed,4,10)),' ');
			writeln(fichier);
		end;
	M0:=M;
	end;
					
		close(fichier);
		


DateTimeToSystemTime(Now,tempsf);
writeln(diffTemps(tempsf,temps0));


{
for i := 1 to 10 do
	begin
	for p in [14,97,40,18,113] do 
		write(p,'  ');
	writeln;
	end;
}
end.
