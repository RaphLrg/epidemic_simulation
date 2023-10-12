program vecteur;

uses sysutils;

const Xmax           = 11;
	  Intervalle     = 30000;			// nombre de subdivisions de l'intervalle
	  
						//modifier ici
	  //##########################################################################################################
	  //##########################################################################################################	  	  
	  Ti             = 0;
	  Tf             = 400;
	  
	  betaA          =0.4;				//taux de transmission Asyptomatique
	  betaB          =0.3;				//taux de transmission Bénin
	  betaG          =0.2;				//taux de transmission Grave
	  
	  lambdaI        =4;				//temps d'incubation
	  lambdaB        =7;				//temps d'infection benin
	  lambdaG        =10;				//temps d'infection grave
	  lambdaH        =8;				//temps d'infection hopital
	  lambdaQ        =10;				//temps d'infection contamination
	  
	  PA			 =0;//.02;				//proba d'aller se faire tester
	  PB			 =0;//.2;
	  PG			 =0;//.9;
	  
	  muG			 =0.067;			//taux de mortalité grave
	  muH			 =0.0064;			//taux de mortalité hopital
	  
	  alpha          =0.1;				//taux d'infectés graves
	  gamma			 =0.8;				//taux d'infectés asymptomatiques parmis les bénins
	  
	  placesH		 =100;
	  
	  N0             =100000;			//population initiale
	  Gamma0		 =0.0005;			//population initiale infectée
	  
	  //##########################################################################################################
	  //##########################################################################################################	  
	  
	  
	  
type vec 	 = array[1..Xmax]      of Real;							//vecteur colonne de taille Xmax

type Matrice = array[1..Xmax,0..Intervalle] of Real;				//matrice enregistrant toutes les positions des vecteurs




function khi(h : real):real;																		//gestion des places d'hopital
begin
if (h<placesH) then khi := 1
else khi := 0;
end;



function F (t : real; Y : vec) : vec;

begin
F[1] := - (betaA*Y[3] + betaB*Y[4] + betaG*Y[5] )* Y[1] / Y[11];									//S			
F[2] := - F[1] - Y[2]/lambdaI;																		//I
F[3] :=   gamma*(1-alpha)*Y[2]/lambdaI     - Y[3]/lambdaB - PA*Y[3]/lambdaB;						//A
F[4] :=   (1-gamma)*(1-alpha)*Y[2]/lambdaI - Y[4]/lambdaB - PB*Y[4]/lambdaB; 						//B
F[5] :=   alpha*Y[2]/lambdaI			   - Y[5]/lambdaG - PG*Y[5]/lambdaG - muG*Y[5];				//G
F[6] :=   PA*Y[3] + PB*Y[4]    - Y[6]/lambdaQ;														//QB
F[7] :=   (1-khi(Y[9]))*PG*Y[5]     -Y[7]/lambdaQ - muG*Y[7];										//QG
F[8] :=   muH*Y[9] + muG*Y[5] + muG*Y[7];															//M
F[9] :=   khi(Y[9])*PG*Y[5] -Y[9]/lambdaH - muH*Y[9];												//H
F[10]:=   Y[3]/lambdaB + Y[4]/lambdaB + Y[5]/lambdaG + Y[6]/lambdaQ + Y[7]/lambdaQ + Y[8]/lambdaH;	//R
F[11]:=   -F[9];																					//N																					//N
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

p := 100;

nom := 'export.txt';


		assign(fichier,nom);
		rewrite(fichier);
			for i := 0 to p do 
				begin
				write  (fichier,FloatToStrF(i*dt * (intervalle div p),ffFixed,4,3),' ');
				write  (fichier,FloatToStrF(M[1,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[2,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[3,(intervalle div p)*i] + M[4,(intervalle div p)*i] + M[5,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[6,(intervalle div p)*i] + M[7,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[8,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[9,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[10,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[11,(intervalle div p)*i],ffFixed,4,10));
				writeln(fichier);
				end;
		close(fichier);



end.
