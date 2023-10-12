program vecteur;

uses sysutils;

const Xmax           = 5;
	  Intervalle     = 10000;			// nombre de subdivisions de l'intervalle
	  Ti             = 0;
	  Tf             = 254;				//temps de l'épidémie
	  
	  beta           =0.3;				//taux de transmission
	  lambda         =7;				//temps d'infection
	  mu			 =0.01;				//taux de mortalité
	  
	  N0             =100000;				//population initiale
	  Gamma0		 =0.005;				//population initiale infectée
	  
//var beta : real;
//	tab_beta : array[1..intervalle] of real;
type vec 	 = array[1..Xmax]      of Real;							//vecteur colonne de taille Xmax

type Matrice = array[1..Xmax,0..Intervalle] of Real;							//matrice enregistrant toutes les positions des vecteurs


function strv_to_strp(s : string) : string;
var i : integer;
	coord : string;
	c:char;
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



function F (t : real; Y : vec) : vec;

begin
F[1] := - beta * Y[1] * Y[2] / Y[5];									
F[2] :=   beta * Y[1] * Y[2] / Y[5] - (1/lambda) * Y[2] - mu * Y[2];
F[3] :=   (1/lambda)  * Y[2];
F[4] :=   mu *          Y[2];
F[5] :=  -mu *			Y[2]; 
end;

function somme_vec(X1,X2 : vec) : vec;					   						//somme de 2 vec
var i : integer;
begin
for i := 1 to Xmax do somme_vec[i] := X1[i] + X2[i];
end;

function Produit_vec(X : vec; k : real) : vec;									//produit d'un vec par un scalaire
var i : integer;
begin
for i := 1 to Xmax do Produit_vec[i] := k * X[i];
end;


procedure etapes_infinitesimale(x : integer;dt : real; var M : matrice; var Yi : vec );
var i : integer;
	Y    : vec;
	tx  : real;
begin


	begin
			tx := x * dt + Ti;
			//beta:= tab_beta[trunc(tx)+1];
			Y  := somme_vec(    Yi, 																	//calcul de Y_x+1
								produit_vec(  F    ( tx + (dt/2),
													 somme_vec(Yi , produit_vec( F (tx,Yi),(dt/2))))
											  , 
											  dt
											)
							);
			for i := 1 to xmax do M[i,x+1] := Y[i];
			Yi := Y;
	end;
end;

//#################################################################################################################################
//#################################################################################################################################

	//partie graphes





//#################################################################################################################################
//#################################################################################################################################

var dt, t, tx, R0    : Real;
	Y,Yi,Y0      : vec;
	M            : matrice;
	x,i,p 		 : integer;		
	nom,s 		 : string;
	fichier		 : text;	
begin
Y0[1] := (1-Gamma0)*N0; //Sain
Y0[2] := Gamma0 * N0;	//Infecte
Y0[3] := 0;				//Remis
Y0[4] := 0;				//Mort
Y0[5] := N0;			//Pop totale
//Y0[] := 
//Y0[] := 

dt := (Tf-Ti)/Intervalle;
Yi := Y0;

for i := 1 to xmax do M[i,0] := Y0[i];





{
assign(fichier,'tri2.txt');
reset(fichier);
for x := 1 to Tf do 
	begin
	readln(fichier,s);
	tab_beta[x] := StrToFloat(s)/Lambda;
	writeln(tab_beta[x]:2:4);
	end;
close(fichier);

}




for x := 0 to Intervalle-1 do etapes_infinitesimale(x,dt,M,Yi);



p := 100;
{
for i := 0 to p do 
				begin
				write  (FloatToStrF(i*dt * (intervalle div p),ffFixed,4,3),' ');
				write  (FloatToStrF(M[1,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (FloatToStrF(M[2,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (FloatToStrF(M[3,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (FloatToStrF(M[4,(intervalle div p)*i],ffFixed,4,10),' ');
				writeln(FloatToStrF(M[5,(intervalle div p)*i],ffFixed,4,10));
				end;
				
				
}
nom := 'export.txt';

	begin
		assign(fichier,nom);
		rewrite(fichier);
{
		writeln(fichier,p,' ',xmax,' ',tf,' ',n0);}
		write(fichier,'Temps ');
		write(fichier,'Sain ');
		write(fichier,'Infecte ');
		write(fichier,'Remis ');
		write(fichier,'Mort ');
		writeln(fichier,'Total');

			for i := 0 to p do 
				begin
				write  (fichier,strv_to_strp(FloatToStrF(i*dt * (intervalle div p),ffFixed,4,3)),' ');
				for x := 1 to xmax do 
				write  (fichier,strv_to_strp(FloatToStrF(M[x,(intervalle div p)*i],ffFixed,4,10)),' ');
				writeln(fichier);
				end;
		close(fichier);
	end;
end.
