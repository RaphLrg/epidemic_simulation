program vecteur;

uses sysutils;

const Xmax           = 7;
	  Intervalle     = 10000;			// nombre de subdivisions de l'intervalle
	  
						//modifier ici
	  //##########################################################################################################
	  //##########################################################################################################	  
	  Ti             = 0;
	  Tf             = 120;
	  
	  beta           =0.6;				//taux de transmission
	  
	  lambdaB        =7;				//temps d'infection benin
	  lambdaG        =14;				//temps d'infection grave
	  lambdaH        =10;				//temps d'infection hopital
	  
	  muG			 =0.1;				//taux de mortalité grave
	  muH			 =0.01;				//taux de mortalité hopital
	  
	  alpha          =0.05;				//taux d'infectés graves
	  
	  placesH		 =1000;
	  
	  N0             =100000;			//population initiale
	  Gamma0		 =0.05;			//population initiale infectée
	  			
	  //##########################################################################################################
	  //##########################################################################################################	  

type vec 	 = array[1..Xmax]      of Real;							//vecteur colonne de taille Xmax

type Matrice = array[1..Xmax,0..Intervalle] of Real;				//matrice enregistrant toutes les positions des vecteurs





{
function equa_diff(t, x1,x2 : Real) : Real;    				// on peut rajouter des xi ; i = Xmax
// on etablie l'equation dif : f(n) (t) = F (  t, f(t), f(1)(t) , ... , f(n-1) (t)  )
begin

equa_diff := -0.4*x2 -10 * sin(x1);								//EQUA DIFF ICI
end;
}

function khi(h : real):real;																			//places hopital
begin

	if (h<placesH) then khi := 1																		// si il reste des places X=1
	else 				khi := 0;																		//sinon 				  X=0

end;

function F (t : real; Y : vec) : vec;

begin

F[1] := - beta * Y[1] * ( Y[2] + Y[3] ) / Y[7];															//S	
		
F[2] :=   (1-alpha)*beta * Y[1] * ( Y[2] + Y[3] ) / Y[7] -         (1/lambdaB) * Y[2] ;					//IB

F[3] :=   (1-khi(Y[4]))*alpha*beta*Y[1] * ( Y[2] + Y[3] ) / Y[7] - (1/lambdaG) * Y[3] - muG * Y[3] ;	//IG

F[4] :=   khi(Y[4])*alpha * beta * Y[1] * ( Y[2] + Y[3] ) / Y[7] - (1/lambdaH) * Y[4] - muH * Y[4] ;	//H

F[5] :=   muG * Y[3] + muH * Y[4] ;																		//M

F[6] :=   (1/lambdaB) * Y[2] + (1/lambdaG) * Y[3] + (1/lambdaH) * Y[4];									//R

F[7] :=   - F[5];																						//N

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
Y0[2] := Gamma0 * N0;	//Infecte benin
Y0[3] := 0;				//infecte grave 
Y0[4] := 0;				//hopital
Y0[5] := 0;				//mort
Y0[6] := 0;				//retablis
Y0[7] := N0;			//totale

dt := (Tf-Ti)/Intervalle;
Yi := Y0;

for i := 1 to xmax do M[i,0] := Y0[i];

for x := 0 to Intervalle-1 do etapes_infinitesimale(x,dt,M,Yi);

p := 1000;

				
				
nom := 'export.txt';

		assign(fichier,nom);
		rewrite(fichier);
			for i := 0 to p do 
				begin
				write  (fichier,FloatToStrF(i*dt * (intervalle div p),ffFixed,4,3),' ');
				write  (fichier,FloatToStrF(M[1,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[2,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[3,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[4,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[5,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[6,(intervalle div p)*i],ffFixed,4,10),' ');
				writeln(fichier,FloatToStrF(M[7,(intervalle div p)*i],ffFixed,4,10));
				
				end;
		close(fichier);
end.
