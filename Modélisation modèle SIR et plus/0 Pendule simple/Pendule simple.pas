program vecteur;

uses sysutils;

const Xmax           = 2;				//nombre de composante du vecteur Y
	  Intervalle     = 10000;			// nombre de subdivisions de l'intervalle
	  
	  
				// modifier des valeures ici
	  //##########################################################################################################
	  //##########################################################################################################
	  Ti             = 0;				//temps initiale s
	  Tf             = 20;				//temps final    s
	  g              =9.81;				//acceleration terrestre
	  l              =1;				//longeur du pendule en metre
	  Theta0         =0.95*pi;			//angle initial en rad
	  Vitesse0		 =0;				//vitesse initiale du pendule en rad/s
	  //##########################################################################################################
	  //##########################################################################################################
	  
	  
	  
	  
type vec 	 = array[1..Xmax]      of Real;							//vecteur colonne de taille Xmax

type Matrice = array[1..Xmax,0..Intervalle] of Real;				//matrice enregistrant toutes les positions des vecteurs

function F (t : real; Y : vec) : vec;
begin
F[1] := Y[2]	;								
F[2] := -(g/l)*sin(Y[1]);
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
			tx := x * dt + Ti; 																			//temps correspondant à l'étape
			
			Y  := somme_vec(    Yi, 																	//calcul de Y_x+1 par schéma du point milieu
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

var dt, t, tx    : Real;
	Y,Yi,Y0      : vec;
	M            : matrice;
	x,i,p 		 : integer;		
	nom 		 : string;
	fichier		 : text;	
begin
Y0[1] := Theta0;
Y0[2] := Vitesse0;
//Y0[] := 
//Y0[] := 

dt := (Tf-Ti)/Intervalle;
Yi := Y0;

for i := 1 to xmax do M[i,0] := Y0[i];

for x := 0 to Intervalle-1 do etapes_infinitesimale(x,dt,M,Yi);



		//nombres de valeures exportées
p := 1000;
		//nom du fichier d'export
nom := 'export.txt';
	begin
		assign(fichier,nom);
		rewrite(fichier);
			for i := 0 to intervalle div tf do 
				begin
				write  (fichier,FloatToStrF(i*dt * (intervalle div p),ffFixed,4,3),' ');
				writeln(fichier,FloatToStrF(M[1,(intervalle div p)*i],ffFixed,4,10),' ');
				end;
		close(fichier);
	end;
end.
