program vecteur;

uses sysutils,crt;

const Xmax           = 11;
	  ville_max      = 200;				// nombre max de ville
	  //Mmax           = 70;				// taille de plus grande matrice = max ( ville_max ; x_max )	  
	  
	  Intervalle     = 6000;			// nombre de subdivision de l'intervalle
	  Ti             = 0;
	  Tf             = 200;
	  
	  
	  //beta           =0.2;				//taux de transmission
	  lambdaI        =3;				//temps d'incubation
	  lambdaB        =11.5;				//temps d'infection benin
	  lambdaG        =11.5;				//temps d'infection grave
	  lambdaH        =9.8;				//temps d'infection hopital
	  lambdaQ        =14;				//temps de mise en quarantaine
	  
	  
	  PA			 =0.05;				//proba d'aller se faire tester
	  PB			 =0.6;
	  PG			 =0.9;
	  
	  muG			 =0.0537;			//taux de mortalité grave
	  muH			 =0.015;			//taux de mortalité hopital
	  
	  alpha          =0.0857;				//taux d'infectés graves
	  gamma			 =0.547;				//taux d'infectés asymptomatiques parmis les bénins
	  
	  placesHpourcent=0.006;			//1 pour milles
	  
	  R0			 =3;				//R0 moyen de l'épidémie
	  
	  
type vec             = array[1..Xmax]      of Real;								//vecteur colonne de taille Xmax
     Matrice_totale  = array[1..ville_max,1..Xmax] of Real;       //matrice enregistrant toutes les positions des vecteurs de chaques villes
     laplacien       = array[1..ville_max,1..ville_max] of real;

	 //big_Matrice     = array[1..Mmax,1..Mmax] of real;
	 Les_voyageurs   = set of 1..Xmax;
	 tab_densite     = array[1..ville_max] of integer;
	 champs = record
	 A,B,G : real
	 end;
	
	VillesExportNom = (Narbonne,Marseille,Toulouse,Chateauroux,Perpignan,Paris);
	
	
var  beta	: array[1..ville_max] of champs;
	 placeH : array[1..ville_max] of real;
	 
	 Total,Total_jour : array[1..4] of Real;
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
			placeH[i] := placesHpourcent*N0;
			
			M0 [i,1] := (1-Gamma)*N0;									//Sain
			M0 [i,2] := Gamma * N0;    									//Infecte incubation
			M0 [i,3] := 0;												//Asymptomatique
			M0 [i,4] := 0;												//Benin
			M0 [i,5] := 0;												//Grave
			M0 [i,6] := 0;												//Q A et B
			M0 [i,7] := 0;												//Q G
			M0 [i,8] := 0;												//M
			M0 [i,9] := 0;												//H
			M0 [i,10] := 0;												//R
			M0 [i,11] := N0;											//N
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
	
		
function khi(ville : integer;h : real):real;																		//gestion des places d'hopital
begin
if (h<placeH[ville]) then khi := 1
else khi := 0;
end;



function F (ville : integer; Y : vec) : vec;

begin
F[1] := - (beta[ville].A*Y[3] + beta[ville].B*Y[4] + beta[ville].G*Y[5] )* Y[1] / Y[11];			//S			
F[2] := - F[1] - Y[2]/lambdaI;																		//I
F[3] :=   gamma*(1-alpha)*Y[2]/lambdaI     - Y[3]/lambdaB - PA*Y[3]/LambdaB;						//A
F[4] :=   (1-gamma)*(1-alpha)*Y[2]/lambdaI - Y[4]/lambdaB - PB*Y[4]/LambdaB; 						//B
F[5] :=   alpha*Y[2]/lambdaI			   - Y[5]/lambdaG - PG*Y[5]/LambdaG;						//G
F[6] :=   PA*Y[3]/LambdaB + PB*Y[4]/LambdaB    - Y[6]/lambdaQ;										//QB
F[7] :=   (1-khi(ville,Y[9]))*PG*Y[5]/LambdaG     -Y[7]/lambdaQ - muG*Y[7];							//QG
F[8] :=   muH*Y[9] + muG*Y[5] + muG*Y[7];															//M
F[9] :=   khi(ville,Y[9])*PG*Y[5] -Y[9]/lambdaH - muH*Y[9];											//H
F[10]:=   Y[3]/lambdaB + Y[4]/lambdaB + Y[5]/lambdaG + Y[6]/lambdaQ + Y[7]/lambdaQ + Y[8]/lambdaH;	//R
F[11]:=   -F[8];																					//N

//#################################### total/jour
Total_jour[1] :=Total_jour[1] - F[1];													//total infectes
Total_jour[2] :=Total_jour[2] + PA*Y[3]/lambdaB + PB*Y[4]/lambdaB + PG*Y[5]/lambdaG;    //total infectes connues
Total_jour[3] :=Total_jour[3] + khi(ville,Y[9])*PG*Y[5];                              	//total hopital
Total_jour[4] :=Total_jour[4] + F[8];                              						//total mort
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
			
			//############################ total
			Total[1]:=Total[1] + Y[2]+Y[3]+Y[4]+Y[5]+Y[6]+Y[7]+Y[9];	//total infectes
			Total[2]:=Total[2] + Y[6]+Y[7]+Y[9];						//total infectes connues
			Total[3]:=Total[3] + Y[9];									//total hopital
			Total[4]:=Total[4] + Y[8];									//total mort
			//############################
			
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
	villesExport : VillesExportNom;
	champsEqua  : array[1..xmax] of string;
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
voyageurs := [1,2,3,4,5,10];                       // mettre ici les gens qui voyagent
n_n       := 11; 								// place de N dans l'equadiff
//##########
//##########
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
	begin
	beta[i].A :=  R0*(0.5+((ln(densite[i])-ln(dmin))/(ln(dmax)-ln(dmin)))) / LambdaB;
	beta[i].B :=  R0*(0.5+((ln(densite[i])-ln(dmin))/(ln(dmax)-ln(dmin)))) / LambdaB;
	beta[i].G :=  R0*(0.5+((ln(densite[i])-ln(dmin))/(ln(dmax)-ln(dmin)))) / LambdaG;
	end;
close(fichier);







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
{
champsEqua[1] := 'S';
champsEqua[2] := 'I';
champsEqua[3] := 'A';
champsEqua[4] := 'B';
champsEqua[5] := 'G';
champsEqua[6] := 'QB';
champsEqua[7] := 'QG';
champsEqua[8] := 'M';
champsEqua[9] := 'H';
champsEqua[10] := 'R';
champsEqua[11] := 'N';
for villesExport in VillesExportNom do
	for i := 1 to xmax do
		write (fichier, villesExport,'_',champsEqua[i],' ');
}
write(fichier,'Inf InfC Hosp Mort Inf_J InfC_J Hosp_J Mort_J'); 



writeln(fichier);

cursoroff;
p := 400;
for x := 0 to Intervalle-1 do 
	begin
	
	for i := 1 to 4 do
		begin
		Total[i] := 0;
		Total_jour[i] :=0;
		end;
	
	etapes_infinitesimale(x,villes,dt,M,M0,L,n_n,voyageurs);
	if (x mod 20 = 0) then 
		begin
		gotoxy(10,10);
		writeln('       ');
		gotoxy(10,10);
		writeln(100*x/intervalle :3:2,' %');
		
		end;
	if (x mod (intervalle div p)) = 0 then 
		begin
			write  (fichier,strv_to_strp(FloatToStrF(x*dt,   ffFixed,4,3)) ,' ');
{
			for i in [14,97,40,18,113,50] do
			for n_n := 1 to xmax do 
					write  (fichier,strv_to_strp(FloatToStrF(M[i,n_n],ffFixed,4,10)),' ');
}
			for i := 1 to 4 do
				write  (fichier,strv_to_strp(FloatToStrF(Total[i],ffFixed,4,10)),' ');
			for i := 1 to 4 do
				write  (fichier,strv_to_strp(FloatToStrF(Total_jour[i],ffFixed,4,10)),' ');
			
			
			writeln(fichier);
		end;
	M0:=M;
	end;
					
		close(fichier);
		


DateTimeToSystemTime(Now,tempsf);
gotoxy(10,10);
writeln('       ');
gotoxy(10,10);
writeln('Calcule en ',diffTemps(tempsf,temps0),' sec');

{
for i := 1 to 10 do
	begin
	for p in [14,97,40,18,113] do 
		write(p,'  ');
	writeln;
	end;
}
end.
