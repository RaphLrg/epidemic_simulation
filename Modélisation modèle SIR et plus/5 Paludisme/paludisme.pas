program vecteur;

uses sysutils;

const Xmax           = 11;
	  Intervalle     = 3000;			// nombre de subdivisions de l'intervalle
	  Ti             = 0;
	  Tf             = 400;
	  
	  alpha          = 0.05;                //taux de guérison des moustiques 
	  
	  
	  gamma          =0.2;				//nombre de bebe par moustique en moyenne 
	  betaV     	=0.09;				//taux de transmission moustique_humain
	  betaH			 =0.09;				//taux de transmision humain-moustique 
	  
	  lambdaL        =10;				//temps pour qu'une larve devienne moustique
	  lambdaI       =7;					//temps d'incubation
	  lambdaR       =25;				//temps d'infection (jusqu'à etre remis)
	  
	  muC		 =0.0067;			 //taux de mortalité humain
	  muLE		 =0.2;			    //taux de mortalité larve pendant épidémie 
// épidemie quand 5% de la population infectée  
	  muLN		=0.15;				//taux de mortalité larve conditions normales 
	  muM	     =0.07;	            //taux de mortalité moustiques 
	  muP	     =0.07;				//taux de mortalité moustiques parasités 
	  
	  M_init     =50000;			//population initiale moustique
	  L_init     =60000;            //population initiale larve
	  P_init     =2500;		     	//population initiale moustiques infectées
	  H_init     =100000 ;          // pop initiale humain 
	  I_init	= 20;				// pop initiale humain infectés
	  

type vec 	 = array[1..Xmax]      of Real;							//vecteur colonne de taille Xmax

type Matrice = array[1..Xmax,0..Intervalle] of Real;				//matrice enregistrant toutes les positions des vecteurs


function khi(i : real;h : real):real;																			//muL 
begin

	if (i<0.03*h) then khi := 1																		// si normal X=1
	else 			khi := 0;																		//sinon épidemie	 X=0

end;

function strv_to_strp(s : string) : string;var i : integer;	coord : string;	c : char;begin			i:=1;			coord:='';			c:=s[i];				repeat					coord := coord+c;					i:=i+1;					c:=s[i];									until (c=',')or(i=length(s)+1);			if not (i=length(s)+1) then			begin			coord := coord+'.';			i:=i+1;			c:=s[i];							repeat					coord := coord+c;					i:=i+1;					c:=s[i];				until i=length(s)+1;			end;		strv_to_strp:= coord;		end;



function F (t : real; Y : vec) : vec;

begin
F[1] := (gamma *Y[2])- ((1/lambdaL) *Y[1]) - (muLE*(1-khi(Y[5],Y[9]))*Y[1])-(muLN*(khi(Y[5],Y[9]))*Y[1]);				//L		
F[2] := 1/lambdaL *Y[1]- muM* Y[2]-betaH *((Y[2]*Y[5])/Y[9])+ alpha*Y[8];												//M
F[3] := (muLE*(1-khi(Y[5],Y[9]))*Y[1])+(muLN*(khi(Y[5],Y[9]))*Y[1])+muM* Y[2]+muP* Y[8];								//D
F[4] := -betaV *((Y[4]*Y[8])/Y[11]); 								        											//S
F[5] := 1/lambdaI *Y[10]- muC *Y[5] - 1/lambdaR *Y[5];																	//I
F[6] :=  muC *Y[5];														          									  	//C
F[7] := 1/lambdaR *Y[5];											  													//R
F[8] := betaH *((Y[2]*Y[5])/Y[9])-muP* Y[8]-alpha*Y[8]; 					    										//P
F[9] := - muC *Y[5];																									// H pop totale humain
F[10]:= betaV *((Y[4]*Y[8])/Y[11]) - 1/lambdaI *Y[10];																	//I incub
F[11]:= 1/lambdaL *Y[1]-muM* Y[2]-muP* Y[8];					//V pop totale moustique 
										   
										   
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
Y0[1] := L_init;         //L
Y0[2] := M_init;	    //M
Y0[3] := 0;				//D
Y0[4] := H_init-I_init;				//S
Y0[5] := I_init;				//I
Y0[6] := 0;				//C
Y0[7] := 0;				//R
Y0[8] := P_init;		//P
Y0[9] := H_init;		//H
Y0[10]:= 0;				//I incub
Y0[11]:= M_init+P_init;		        //V


dt := (Tf-Ti)/Intervalle;
Yi := Y0;

for i := 1 to xmax do M[i,0] := Y0[i];

for x := 0 to Intervalle-1 do etapes_infinitesimale(x,dt,M,Yi);

p := 100;

nom := 'export.txt';
if fileExists(nom) then
	begin
		assign(fichier,nom);
		rewrite(fichier);
		
				for i := 0 to p do 
				begin
				write  (fichier,FloatToStrF(i*dt * (intervalle div p),ffFixed,4,3),' ');
				write  (fichier,FloatToStrF(M[1,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[2,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[3,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[8,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[11,(intervalle div p)*i],ffFixed,4,10),' ');
				
				write  (fichier,FloatToStrF(M[4,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[5,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[10,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[6,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[7,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[9,(intervalle div p)*i],ffFixed,4,10));
				writeln(fichier);
				end;
		close(fichier);
	end;
	


end.
