program vecteur;

uses sysutils;

const Xmax           = 11;
	  Intervalle     = 32675;			// nombre de subdivisions de l'intervalle
	  Ti             = 0;
	  Tf             = 1000;
	  
	  betaA          =1;				//taux de transmission Asyptomatique
	  betaB          =1;				//taux de transmission Bénin
	  betaG          =1;				//taux de transmission Grave
	  
	  lambdaI        =4;				//temps d'incubation
	  lambdaB        =7;				//temps d'infection benin
	  lambdaG        =10;				//temps d'infection grave
	  lambdaH        =8;				//temps d'infection hopital
	  lambdaQ        =10;				//temps d'infection contamination
	  
	  PA			 =0.02;				//proba d'aller se faire tester
	  PB			 =0.2;
	  PG			 =0.9;
	  
	  muG			 =0.067;			//taux de mortalité grave
	  muH			 =0.0064;			//taux de mortalité hopital
	  
	  alpha          =0.4;				//taux d'infectés graves
	  gamma			 =0.8;				//taux d'infectés asymptomatiques parmis les bénins
	  
	  placesH		 =1000;
	  
	  N0             =100000;			//population initiale
	  Gamma0		 =0.0005;			//population initiale infectée
	  

type vec 	 = array[1..Xmax]      of Real;							//vecteur colonne de taille Xmax

type Matrice = array[1..Xmax,0..Intervalle] of Real;				//matrice enregistrant toutes les positions des vecteurs





{
function equa_diff(t, x1,x2 : Real) : Real;    				// on peut rajouter des xi ; i = Xmax
// on etablie l'equation dif : f(n) (t) = F (  t, f(t), f(1)(t) , ... , f(n-1) (t)  )
begin

equa_diff := -0.4*x2 -10 * sin(x1);								//EQUA DIFF ICI
end;
}

function khi(h : real):real;																		//gestion des places d'hopital
begin
if (h<placesH) then khi := 1
else khi := 0;
end;



function F (t : real; Y : vec) : vec;

begin
F[1] := - (betaA*Y[3] + betaB*Y[4] + betaG*Y[5] )* Y[1] / Y[11];									//S			
F[2] := - F[1] - Y[2]/lambdaI;																		//I
F[3] :=   gamma*(1-alpha)*Y[2]/lambdaI     - Y[3]/lambdaB - PA*Y[3];								//A
F[4] :=   (1-gamma)*(1-alpha)*Y[2]/lambdaI - Y[4]/lambdaB - PB*Y[4]; 								//B
F[5] :=   alpha*Y[2]/lambdaI			   - Y[5]/lambdaG - PG*Y[5];								//B
F[6] :=   PA*Y[3] + PB*Y[4]    - Y[6]/lambdaQ;														//QB
F[7] :=   (1-khi(Y[8]))*PG*Y[5] -Y[7]/lambdaQ - muG*Y[7];											//QB
F[8] :=   khi(Y[8])*PG*Y[5]     -Y[8]/lambdaH - muH*Y[8];											//M
F[9] :=   muH*Y[8] + muG*Y[5] + muG*Y[7];															//H
F[10]:=   Y[3]/lambdaB + Y[4]/lambdaB + Y[5]/lambdaG + Y[6]/lambdaQ + Y[7]/lambdaQ + Y[8]/lambdaH;	//R
F[11]:=   -F[9];																					//N
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

procedure etapes_infinitesimale(x : integer;dt : real; var M : matrice; var Yi : vec );					//resolution des equa diff par le schéma du point milieu
var i : integer;
	Y    : vec;
	tx  : real;
begin


	begin
			tx := x * dt + Ti;
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

var dt	 	     : Real;
	Yi,Y0        : vec;
	M            : matrice;
	x,i,p 		 : integer;		
	nom 		 : string;
	fichier		 : text;	
begin
Y0[1] := (1-Gamma0)*N0; //Sain
Y0[2] := Gamma0 * N0;	//incubation
Y0[3] := 0;				//infecte asyptomatique 
Y0[4] := 0;				//infecte bénin
Y0[5] := 0;				//infecte grave
Y0[6] := 0;				//quarantaine bénin
Y0[7] := 0;				//quarantaine grave
Y0[8] := 0;				//hopital
Y0[9] := 0;				//mort
Y0[10]:= 0;				//retablis
Y0[11]:= N0;			//total

dt := (Tf-Ti)/Intervalle;
Yi := Y0;

for i := 1 to xmax do M[i,0] := Y0[i];

for x := 0 to Intervalle-1 do etapes_infinitesimale(x,dt,M,Yi);

p := 990;
{
for i := 0 to p do 
				begin
				write  (FloatToStrF(i*dt * (intervalle div p),ffFixed,4,3),' ');
				write  (FloatToStrF(M[1,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (FloatToStrF(M[2,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (FloatToStrF(M[3,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (FloatToStrF(M[4,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (FloatToStrF(M[5,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (FloatToStrF(M[6,(intervalle div p)*i],ffFixed,4,10),' ');
				writeln(FloatToStrF(M[7,(intervalle div p)*i],ffFixed,4,10));
				end;
}
{
nom := 'export.txt';
if fileExists(nom) then
	begin
		assign(fichier,nom);
		rewrite(fichier);
			for i := 0 to p do 
				begin
				write  (fichier,FloatToStrF(i*dt * (intervalle div p),ffFixed,4,3),' ');
				for x := 1 to xmax do 
				write  (fichier,FloatToStrF(M[x,(intervalle div p)*i],ffFixed,4,10),' ');
				writeln(fichier);
				end;
		close(fichier);
	end;
}

nom := 'export quarantaine.txt';

assign(fichier,nom);
rewrite(fichier);
writeln(fichier, 'Temps Sain Incubation Infectes Quarantaine Hopital Morts Retablis Total');
	for i := 0 to p do 
		begin
		write  (fichier,strv_to_strp(FloatToStrF(i*dt * (intervalle div p),ffFixed,4,3)),' ');
		write  (fichier,strv_to_strp(FloatToStrF(M[1,(intervalle div p)*i],ffFixed,4,10)),' ');
		write  (fichier,strv_to_strp(FloatToStrF(M[2,(intervalle div p)*i],ffFixed,4,10)),' ');
		write  (fichier,strv_to_strp(FloatToStrF(M[3,(intervalle div p)*i] + M[4,(intervalle div p)*i] + M[5,(intervalle div p)*i],ffFixed,4,10)),' ');
		write  (fichier,strv_to_strp(FloatToStrF(M[6,(intervalle div p)*i] + M[7,(intervalle div p)*i],ffFixed,4,10)),' ');
		write  (fichier,strv_to_strp(FloatToStrF(M[8,(intervalle div p)*i],ffFixed,4,10)),' ');
		write  (fichier,strv_to_strp(FloatToStrF(M[9,(intervalle div p)*i],ffFixed,4,10)),' ');
		write  (fichier,strv_to_strp(FloatToStrF(M[10,(intervalle div p)*i],ffFixed,4,10)),' ');
		write  (fichier,strv_to_strp(FloatToStrF(M[11,(intervalle div p)*i],ffFixed,4,10)));
		writeln(fichier);
		end;
close(fichier);


end.
