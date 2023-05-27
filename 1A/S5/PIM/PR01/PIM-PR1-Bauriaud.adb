--------------------------------------------------------------------------------
--  Auteur   : BAURIAUD Laura
--  Objectif : 
--------------------------------------------------------------------------------

with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Integer_Text_IO;   use Ada.Integer_Text_IO;
with Ada.Calendar;          use Ada.Calendar;
with Ada.Numerics.Discrete_Random;


procedure Multiplications is
	
	-- Réviser les tables de multiplication

    demande : Boolean; -- savoir si on continue à demander une valeur de la table à réviser
    table : Integer; -- table à réviser
    erreur : Integer; -- nombre d'erreurs final
    resultat : Integer; --le résultat de la multiplication posée
    debut : Time; -- heure de début de l'opération
    fin : Time; --heure de fin de l'opération
    tps_moy : Duration; -- le temps moyen pour répondre à une multiplication
    tps : Duration; -- le temps de réponse pour une multiplication (attention format)
    pire_tps : Duration; --le pire temps de réponse
    nb : Integer; -- le nombre de droite demandé
    nb_prec : Integer; -- le nombre de droite précedemment demandé
    pire_nb : Integer; -- le nombre de droite pour lequel l'utilisateur a mis le plus de temps à répondre
    choix : Character; -- choix de l'utilisateur : o (on continue), n (on arrete de réviser)
    continue : Boolean; -- nous permet de savoir si l'utilisateur souhaite continuer à réviser ou non


    	-- package pour obtenir un nombre aléatoire entre [0,10]

	generic
		Lower_Bound, Upper_Bound : Integer;	-- bounds in which random numbers are generated
		-- { Lower_Bound <= Upper_Bound }
	
	package Alea is
	
		-- Compute a random number in the range Lower_Bound..Upper_Bound.
		--
		-- Notice that Ada advocates the definition of a range type in such a case
		-- to ensure that the type reflects the real possible values.
		procedure Get_Random_Number (Resultat : out Integer);
	
	end Alea;

	package body Alea is
	
		subtype Intervalle is Integer range Lower_Bound..Upper_Bound;
	
		package  Generateur_P is
			new Ada.Numerics.Discrete_Random (Intervalle);
		use Generateur_P;
	
		Generateur : Generateur_P.Generator;
	
		procedure Get_Random_Number (Resultat : out Integer) is
		begin
			Resultat := Random (Generateur);
		end Get_Random_Number;
	
	begin
		Reset(Generateur);
	end Alea;

	package Mon_Alea is
		new Alea(0,10);
	use Mon_Alea;

begin 

    loop

	-- Demander la table à réviser
	demande := True;
	while demande loop
	    New_Line;
	    Put("Table à réviser : ");
	    Get(table);
	    demande := (table<0 or table>10);
	    if demande then
		Put("Impossible. La table doit être entre 0 et 10.");
	    else
		Null;
	    end if;
	end loop;

	--Poser les 10 multiplications et compter le nombre d'erreurs commises ainsi que le temps moyen de réponse
	erreur := 0;
	tps_moy := Duration(0.0);
	pire_tps := Duration(0.0);
	pire_nb := 0;
	nb_prec := 11;
	for i in 1..10 loop
		
		--poser une multiplication
	
		loop
			Get_Random_Number(nb); --obetnir un nombre aléatoire
			exit when nb/=nb_prec; --nombre aléatoire différent du précédent
		end loop;
		nb_prec := nb;
		New_Line;
		Put("(M");
		Put(i,1);
		Put(")");
		Put(table,2);
		Put(" x ");
		Put(nb,2);
		Put(" ? ");
	   	debut := Clock;
		Get(resultat);
		fin := Clock;
		tps := fin - debut;
		tps_moy := tps_moy + tps;
	    	if (resultat=table*nb) then
			Put_Line("Bravo !");
	   	else
			Put_Line("Mauvaise réponse.");
			erreur := erreur +1;
	    	end if;
		
		-- traiter le cas où le nouveau temps de réponse est le pire
	   	if tps>pire_tps then
			pire_tps := tps;
			pire_nb := nb;
	    	else
			Null;
	    	end if;
	    	tps_moy := tps_moy + tps;

	end loop;

	-- calculer le temps moyen de réponse
	tps_moy := tps_moy / 10.0;
	

	-- Afficher un message en fonciton du nombre d'erreurs commises
	New_Line;
	case erreur is
	    when 0 => Put_Line("Aucune erreur. Excellent !");
	    when 1 => Put_Line("Une seule erreur. Très bien.");
	    when 10 => Put_Line("Tout faux ! Volontaire");
	    when 6..9 => 
		Put("Seulement ");
		Put(10-erreur,2);
		Put(" bonnes réponses. Il faut apprendre la table de ");
		Put(table,1);
		Put(".");
	    when others =>
		New_Line;
		Put(erreur);
		Put("erreurs. Il faut encore retravailler la table des ");
		Put(table,1);
		New_Line;
	end case;

	--Afficher un message en fonction du pire temps de réponse
	if pire_tps > tps_moy + Duration(1.0) then
		New_Line;
		Put("Des hésitations sur la table de ");
		Put(pire_nb,1);
	    	Put(" : " & Duration'Image(pire_tps) );
    		Put(" secondes contre ");
    		Put(Duration'Image(tps_moy));
    		Put(" en moyenne. Il faut certainement la réviser.");
		New_Line;
	else
	       Null;
	end if;

	--Traiter le choix
	New_Line;
	Put("On continue (o/n) ?");
	Get(choix);
	continue := (choix='o' or choix='O');

	exit when False=continue;

	
    end loop;

end multiplications;
