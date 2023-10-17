program vecteur;

uses sysutils;

const Xmax           = 19;
	  intervalle     = 32675; 			// nombre de subdivisions de l'intervalle
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
	  
	  placesH		 =1000;				//places dispo à l'hopital
   taux_confinement  =0.60;				//taux de saturation des hopitaux pour lancer un confinement
   taux_deconfinement=0.20;				//taux de saturation des hopitaux pour lancer un déconfinement
	  omega          =0.5;				//pourcentage de la pop confinée
	  
	  N0             =100000;			//population initiale
	  Gamma0		 =0.0005;			//population initiale infectée


type vec 	 = array[1..Xmax]      of Real;							//vecteur colonne de taille Xmax

type Matrice = array[1..Xmax,0..intervalle] of Real;				//matrice enregistrant toutes les positions des vecteurs





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


procedure confinement(var M : matrice; x : integer);
var S,I,A,B,G,R : real;
begin
S :=M[1,x] ;
I :=M[2,x] ;
A :=M[3,x] ;
B :=M[4,x] ;
G :=M[5,x] ;
//Qb:=Y[6] ;
//Qg:=Y[7] ;
//H
//M
R :=M[10,x];
//N
//Cg:=Y[12];
//Ca:=Y[13];
//Cb:=Y[14];
//Cr:=Y[15];

M[5,x] := (1-omega)*G;
M[12,x]:= omega*(G + alpha*I);

M[3,x] := (1-omega)*A;
M[13,x]:= omega*(A + (1-alpha)*gamma*I);

M[4,x] := (1-omega)*B;
M[14,x]:= omega*(B + (1-alpha)*(1-gamma)*I);

M[1,x] := (1-omega)*S;
M[19,x]:= omega*S;

M[10,x]:= (1-omega)*R;
M[15,x]:= omega*R;

M[2,x] := (1-omega)*I;
end;

procedure deconfinement(var M : matrice ; x : integer);
var S,A,B,G,R,Cg,Ca,Cb,Cr,Cs : real;
begin
S :=M[1,x] ;
//I :=M[2,x] ;
A :=M[3,x] ;
B :=M[4,x] ;
G :=M[5,x] ;
//Qb:=Y[6] ;
//Qg:=Y[7] ;
//H
//M
R :=M[10,x];
//N
Cg:=M[12,x];
Ca:=M[13,x];
Cb:=M[14,x];
Cr:=M[15,x];
Cs:=M[19,x];

M[5,x] := G + Cg;
M[12,x]:= 0;

M[3,x] := A + Ca;
M[13,x]:= 0;

M[4,x] := B + Cb;
M[14,x]:= 0;

M[1,x] := S + Cs;
M[19,x]:= 0;

M[10,x]:= R + Cr;
M[15,x]:= 0;
end;

procedure mesure_confinement(var x,Xconf : integer; var M : matrice);
var H : real;
begin
H := M[8,x];
case Xconf of
	0 : if (H > placesH*taux_confinement) then 
				begin
				Xconf := 1;
				confinement(M,x);
				end
		else Xconf := 0;
	1 : if (H < placesH*taux_deconfinement) then 
				begin
				Xconf := 0;
				deconfinement(M,x);
				end
		else Xconf := 1;
end;
end;



function F (t : real; Y : vec; Xconf : Integer) : vec;
var S,I,A,B,G,Qb,Qg,H,N,Cg,Ca,Cb : real;
	j : integer;
begin
S :=Y[1] ;
I :=Y[2] ;
A :=Y[3] ;
B :=Y[4] ;
G :=Y[5] ;
Qb:=Y[6] ;
Qg:=Y[7] ;
H :=Y[8] ;
//M :=Y[9] ;
//R :=Y[10];
N :=Y[11];
Cg:=Y[12];
Ca:=Y[13];
Cb:=Y[14];
//Cr:=Y[15];

{S} F[1] := - (betaA*A + betaB*B + betaG*G )* S / N;									
{I} F[2] := - F[1] - I/lambdaI;															
{A} F[3] :=   gamma*(1-alpha)*I/lambdaI     - A/lambdaB - PA*A;							
{B} F[4] :=   (1-gamma)*(1-alpha)*I/lambdaI - B/lambdaB - PB*B; 						
{G} F[5] :=   alpha*I/lambdaI			   - G/lambdaG - PG*G;							
{QB}F[6] :=   PA*A + PB*B    - Qb/lambdaQ;												
{QG}F[7] :=   (1-khi(H))*PG*G -Qg/lambdaQ - muG*Qg;										
{H} F[8] :=   khi(H)*PG*G     -H /lambdaH - muH*H + khi(H)*Cg;										
{M} F[9] :=   muH*H + muG*G + muG*Qg + muG*Cg;													
{R} F[10]:=   B/lambdaB + A/lambdaB + G/lambdaG + (Qb/lambdaQ + Qg/lambdaQ + H/lambdaH)*(1-Xconf);	
{N} F[11]:=   -F[9];
{Cg}F[12]:=   -Xconf*Cg - muG*Cg - Cg/lambdaG;
{Ca}F[13]:=   -Ca/lambdaB;																	
{Cb}F[14]:=   -Cb/lambdaB;	
{Cr}F[15]:=   Cg/lambdaG + Ca/lambdaB + Cb/lambdaB + (Qb/lambdaQ + Qg/lambdaQ + H/lambdaH)*Xconf;
for j := 16 to 19 do F[j] := 0;
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


procedure etapes_infinitesimale(x : integer; var Xconf : integer;dt : real; var M : matrice );					//resolution des equa diff par le schéma du point milieu
var i     : integer;
	Y,Yi  : vec;
	tx    : real;
begin

	mesure_confinement(x,Xconf,M);
	for i := 1 to xmax do Yi[i] := M[i,x];

	begin						//equa diff
	
			tx := x * dt + Ti;
			//if Xconf = 1 then writeln(tx : 3 : 2);
			Y  := somme_vec(    Yi, 																	//calcul de Y_x+1
								produit_vec(  F    ( tx + (dt/2),
													 somme_vec(Yi , produit_vec( F (tx,Yi,Xconf),(dt/2))),Xconf)
											  , 
											  dt
											)
							);
							
					//nouveau vecteur
							// 15 premieres equa diff
			for i := 1 to 15 do M[i,x+1] := Y[i]; 
							// Confinés
			M[16,x+1] := 0;
			for i in [19,12,13,14] do M[16,x+1] := M[16,x+1] + M[i,x+1];
							//infectes totals
			M[17,x+1] := 0;
			for i in [3,13,4,14,5,12,6,7,8] do M[17,x+1] := M[17,x+1] + M[i,x+1];
							//infectes connus
			M[18,x+1] := 0;
			for i in [6,7,8] do M[18,x+1] := M[18,x+1] + M[i,x+1];
			
			M[19,x+1] := M[19,x];
	end;
end;

//#################################################################################################################################
//#################################################################################################################################

var dt	 	     : Real;
	Y0           : vec;
	M            : matrice;
	x,i,p,Xconf	 : integer;		
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
Y0[12]:= 0;				//Confinés graves
Y0[13]:= 0;				//Confinés asymptomatiques
Y0[14]:= 0;				//Confinés bénins
Y0[15]:= 0;				//confinés remis
Y0[16]:= 0;				//total des gens confinés
Y0[17]:= 0;				//total des infectés
Y0[18]:= 0;				//infectés connus car dépistés
Y0[19]:= 0;				//confinés sains

Xconf := 0;				//vaut 1 si confinement

dt := (Tf-Ti)/Intervalle;

for i := 1 to xmax do M[i,0] := Y0[i];

for x := 0 to Intervalle-1 do etapes_infinitesimale(x,Xconf,dt,M);

p := 1000;
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
nom := 'export confinement.txt';

assign(fichier,nom);
rewrite(fichier);
writeln(fichier, 'Temps Sain Incubation Asymptotiques Benins Graves QuarantaineB QuarantaineG Hopital Morts RetablisTotal Total ConfinesGrave ConfinesAsymptotique ConfinesBenin ConfinesRetabli ConfinesTotal InfectesTotal InfectesConnu ConfinesSains');
	for i := 0 to p do 
		begin
		write  (fichier,strv_to_strp(FloatToStrF(i*dt * (intervalle div p),ffFixed,4,3)),' ');
		for x := 1 to xmax do 
		write  (fichier,strv_to_strp(FloatToStrF(M[x,(intervalle div p)*i],ffFixed,4,10)),' ');
		writeln(fichier);
		end;
close(fichier);


{
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
				write  (fichier,FloatToStrF(M[3,(intervalle div p)*i] + M[4,(intervalle div p)*i] + M[5,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[6,(intervalle div p)*i] + M[7,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[8,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[9,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[10,(intervalle div p)*i],ffFixed,4,10),' ');
				write  (fichier,FloatToStrF(M[11,(intervalle div p)*i],ffFixed,4,10));
				writeln(fichier);
				end;
		close(fichier);
	end;
}


end.
