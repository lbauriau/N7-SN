with Ada.Strings;               use Ada.Strings;
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Integer_Text_IO;       use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;  use Ada.Text_IO.Unbounded_IO;
with Ada.Command_Line;          use Ada.Command_Line;
with Ada.Exceptions;            use Ada.Exceptions;
with Ada.IO_Exceptions;
with Ada.Calendar;		        use Ada.Calendar;
with lca_table;
with types;                     use types;
with Cache_LA;                  use Cache_LA;




procedure routeur_La is

	Debut: Time;		-- heure de début de l'opération
	Fin: Time;		-- heure de fin de l'opération
	Duree : Duration;

	--------------------------------
	-- Définition des types utilisés
	--------------------------------

   	-- Traitement donnée ancien type
   	destination : Unbounded_String;
  	masque : Unbounded_String;
   	interfac : Unbounded_String;

   	-- Sous programme
	--type T_adresseIP is array(1..4) of Integer;
	--type T_Routes is
	--	record
	--		destination : T_adresseIP;
	--		masque : T_adresseIP;
	--		interf : Unbounded_String;
	--	end record;

	package lca_hachage is
			new lca_table (T_element =>T_Routes);
	use lca_hachage;

	--Comparateur_binaire
	type T_bin_8 is array (1..8) of Integer;
	type T_adresse_bin is array (1..4) of T_bin_8;


	----------------------------------------------------------------
	-- Procédures et fonctions relatives aux adresses_IP
	----------------------------------------------------------------

	procedure prc_afficher_adresse (ad : T_adresseIP) is
	begin
		for i in 1..3 loop
			Put(ad(i));
			Put(".");
		end loop;
		Put(ad(4));
	end prc_afficher_adresse;

	-- Affichage d'une adresse binaire

	procedure prc_afficher_adresse_bin (ad_bin : T_adresse_bin) is
	begin
		for i in 1..4 loop
			for j in 1..8 loop
				Put(ad_bin(i)(j));
			end loop;
			Put(".");
		end loop;
   	end prc_afficher_adresse_bin;



	-- Conversion d'un entier en base 10 en écriture binaire

	function fct_convertir_10_2 ( entier_10 : integer) return T_bin_8 is
		resultat : T_bin_8;
		quotient : Integer;
		k : Integer;
	begin
		quotient := entier_10 ;
		k :=8;
		while (k>=1) loop
			resultat(k) := quotient mod 2;
			quotient := quotient / 2;
			k := k-1;
		end loop;
		return resultat;
	end fct_convertir_10_2;


	-- Conversion d'une adresse_IP en base 10 en écriture binaire

	function fct_convertir_10_2_adresse ( adresse : T_adresseIP) return T_adresse_bin is
		adresse_bin : T_adresse_bin;
	begin
		for k in 1..4 loop
			adresse_bin(k) := fct_convertir_10_2(adresse(k));
		end loop;
		return adresse_bin;
	end fct_convertir_10_2_adresse;


	--Conversion d'un entier en binaire en écriture décimale

	function fct_convertir_2_10 (tab_2 : T_bin_8) return Integer is
		resultat : Integer;
	begin
		resultat := 0;
		for k in 1..7 loop
			resultat := (resultat + tab_2(k))*2;
		end loop;
		resultat := resultat +tab_2(8);
		return resultat;
	end fct_convertir_2_10;


	-- Conversion d'une adresse_IP en base 2 en écriture décimale

	function fct_convertir_2_10_adresse ( adresse_bin : T_adresse_bin) return T_adresseIP is
		adresse_IP : T_adresseIP;
	begin
		for k in 1..4 loop
			adresse_IP(k) := fct_convertir_2_10(adresse_bin(k));
		end loop;
		return adresse_IP;
	end fct_convertir_2_10_adresse;

	--Fonction qui effectue un & bit à bit (utilisée lors de l'application d'un masque).

	function fct_et_bin (elt : T_bin_8; elt_masque : T_bin_8) return T_bin_8 is
	       elt_final : T_bin_8;
	begin
		for k in 1..8 loop
			if (elt(k)=1) and (elt_masque(k)=1) then
				elt_final(k) := 1;
			else
				elt_final(k) := 0;
			end if;
		end loop;
		return elt_final;
	end fct_et_bin;

	--Fonction qui applique un masque à une adresse

	function fct_masque_bin (adresse : T_adresse_bin; masque : T_adresse_bin) return T_adresse_bin is
		adresse_masquee : T_adresse_bin;
		ad_bin : T_bin_8;
		mas_bin : T_bin_8;
	begin
		for k in 1..4 loop
			ad_bin := adresse(k);
			mas_bin := masque(k);
			adresse_masquee(k) := fct_et_bin(ad_bin,mas_bin);
		end loop;
		return adresse_masquee;
  	end fct_masque_bin;



	--Fonction qui compare deux adresse_IP

	function fct_egalite(adresse : T_adresse_bin; masque : T_adresse_bin) return boolean is
		egal : boolean := true;
		i : integer := 1;
		j : integer := 1;
	begin
		while not (i=5) and egal loop
			egal := adresse(i)(j)=masque(i)(j);
			if j = 8 then
				j:= 1;
				i := i+1;
			else
				j := j+1;
			end if;
		end loop;
		return egal;
	end fct_egalite;



	--Fonction qui arrondit un flottant en entier représenté par une chaine de caractère

	function fct_arrondi ( flottant : float) return Unbounded_String is
		chaine : Unbounded_String  := To_Unbounded_String(Float'Image(flottant));
		indice : integer := 1;
  	begin
      		while To_String(chaine)(indice) /= '.' loop
         		indice := indice +1;
     		end loop;
      		chaine :=To_Unbounded_String(To_String( chaine)(1..indice-1));
      		return chaine;
	end fct_arrondi;


   -----------------------------------------------------------------------------------------
   -- Fonction qui effectue une comparaison de deux entiers après l'application d'un masque
   -----------------------------------------------------------------------------------------

	function fct_comp (elt_table : T_Routes; elt_paquet : T_adresseIP) return boolean is
		adresse_bin : T_adresse_bin;
		masque_bine : T_adresse_bin;
		paquet_bin : T_adresse_bin;
		adresse_masquee : T_adresse_bin;
		paquet_masquee : T_adresse_bin;
		resultat : boolean;
	begin
		adresse_bin := fct_convertir_10_2_adresse(elt_table.destination);
		masque_bine := fct_convertir_10_2_adresse(elt_table.masque);
		paquet_bin := fct_convertir_10_2_adresse(elt_paquet);
		adresse_masquee := fct_masque_bin(adresse_bin,masque_bine);
		paquet_masquee := fct_masque_bin(paquet_bin,masque_bine);
		resultat := fct_egalite(adresse_masquee,paquet_masquee);
		return resultat;
	end fct_comp;

   ------------------------------------------------------------------------------------------------
   ------------------------------------------------------------------------------------------------

  	-- Fonction qui renvoie la taille du masque

	function fct_taille_masque (masque : T_adresse_bin) return integer is
		taille : integer := 0;
		i : integer := 1;
		j : integer := 1;
	begin
		while not (i=5) and not (masque(i)(j) = 0) loop
			taille := taille +1;
			if j= 4 then
				j:=1;
				i := i+1;
			else
				j := j+1;
			end if;
		end loop;
		return taille;
   	end fct_taille_masque;


	-- Fonction qui permet d'obtenir un masque allongé de 1 bit

	function fct_masque_allonge (masque : in T_adresseIP) return T_adresseIP is
		masque_bin : T_adresse_bin;
		i : integer;
		j : integer;
		b : boolean;
		new_masque : T_adresseIP;
	begin
		masque_bin := fct_convertir_10_2_adresse(masque);
		b := true;
		i := 1;
		j := 1;
		while b and (j<=4) loop
			while b and (i<=8) loop
				if masque_bin(j)(i) = 0 then
					masque_bin(j)(i) := 1;
					b := false;
				else
					i := i+1;
				end if;
			end loop;
			j := j+1;
			i := 1;
		end loop;
		new_masque := fct_convertir_2_10_adresse(masque_bin);
		return new_masque;
	end fct_masque_allonge;

	-- Cette procédure est utilisée dans la focntion qui renvoie le nouveau masque à ajouter dans le cache

	procedure prc_new_masque (elt : in out T_Routes; table_hach : in T_LCA ) is
	begin
		if Est_Vide(table_hach) then
			Null;
		else
		       if fct_comp(elt,table_hach.element.destination) then
			       elt.masque := table_hach.element.masque;
		       end if;
		       prc_new_masque(elt, table_hach.suivant);
		end if;
	end prc_new_masque;

	-- Fonction qui renvoie le nouveau masque à ajouter dans le cache

	function fct_new_masque (elt : in T_Routes; table_hach : in T_LCA) return T_adresseIP is
		aux_table_hach : T_LCA;
		elt_aux : T_Routes;
	begin
		elt_aux := elt;
		aux_table_hach := table_hach;
		prc_new_masque(elt_aux,aux_table_hach);
		return elt_aux.masque;
	end fct_new_masque;


	----------------------------------------------------------------------------------
	--  Toutes les fonctions et procédures relatives au cache sous forme de LCA	--
	----------------------------------------------------------------------------------

	borne : integer := 10;

	

   	-- Lecture/écriture fichier
   	Entree : File_Type;
   	Paquets: File_Type;
   	Sortie : File_Type;
	Fichier : File_Type;

   	-- Parcours de fichier
   	Ligne : Unbounded_String;
	Nb_caractere : Integer;
	i : Integer := 1;
   	m : Integer;
   	Fini : Boolean := False;
   	reponse : Unbounded_String;
   	interf : Unbounded_String;

   	-- Affichage des lignes d'un fichier
  	procedure prc_Afficher_txt(nom_fichier : Unbounded_String) is
  	begin
     		Open(Entree, In_File, To_String (nom_fichier));
     		New_Line;
     		Put_Line("------------- Table -------------");
      		loop
			Ligne := Get_Line (Entree);
			Put_Line(Ligne);
			Nb_caractere := Length(Ligne);
			Trim (Ligne, Both);
			exit when End_Of_File (Entree);
		end loop;
		Put_Line("---------------------------------");
		New_Line;
		Close(Entree);
	end prc_Afficher_txt;

	-- Fonction qui dit si un fichier est un .txt et dans le répertoire
	--
  	function fct_in_directory(nom_fichier : Unbounded_String) return Boolean is
      		longueur : constant Integer := Length(nom_fichier);
      		comparaison : constant String :=".txt";
      		txt : Boolean;
	begin
		if longueur >= 4 then
			txt := To_String(nom_fichier)(longueur-3..longueur) = comparaison ;
		else
			return False;
		end if;
		Open (Fichier, In_File, To_String(nom_fichier));
		Close (Fichier);
		return txt;
	exception
		when ADA.IO_EXCEPTIONS.NAME_ERROR => return False;
	end fct_in_directory;



   	-- Gestion données
   	table_hach : T_LCA;
   	aux_table_hach : T_LCA;
   	resultat_lca : T_LCA;
   	destination_tb : T_adresseIP;
   	masque_tb : T_adresseIP;
   	interf_tb : Unbounded_String;
   	table_elt : T_Routes;
   	l : integer;
   	taille_m : integer;
	new_masque : T_adresseIP;
	--elt_masque : T_Routes;
	cache : T_Cache_LA;
	aux_cache : T_Cache_LA;
	indice_cache : integer;
	defaut_cache : float;
	nb_demande : float;
   taux_defaut :float;
   rep : Boolean;
   route_cache : T_Routes;
   Compteur : Integer;


   	-- Paramètres par défaut
		--borne : Integer := 10; déclaré précedemment
		politique : Unbounded_String := To_Unbounded_String("FIFO");
		statistique : Boolean := True;
		nom_fichier_routes : Unbounded_String := To_Unbounded_String("table.txt");
		nom_fichier_paquets : Unbounded_String := To_Unbounded_String("paquets.txt");
		nom_fichier_resultats : Unbounded_String := To_Unbounded_String("resultats.txt");

   	-- Argument ligne commande
   	nb_argument : constant Integer := Argument_Count;

begin

	-- Récupérer l'heure (heure de début)
   Debut := Clock;
   politique  := To_Unbounded_String("FIFO");
   Compteur  := 0;
   borne :=10 ;

   ----------------------------------------------------------------------------
   --------------------- Gestion de la ligne de commande ----------------------

	for i in 1..nb_argument loop
      		if To_String(To_Unbounded_String(Argument(i)))(1) /= '-' then
         		null;
      		else
         		case To_String(To_Unbounded_String(Argument(i)))(2) is
            			when 'c' => borne := Integer'Value(Argument(i+1));
            			when 'P' =>
					if ((Argument(i+1) /= "LRU") and (Argument(i+1) /= "LFU") and (Argument(i+1) /= "FIFO") ) then
						Put_Line("Erreur politique, politique disponible : FIFO, LRU, LFU. Choix politique par defaut : FIFO");
					else
						politique := To_Unbounded_String(Argument(i+1));
					end if;
				when 'S' => statistique := False;
				when 's' => statistique := True;
				when 't' =>
					if fct_in_directory( To_Unbounded_String(Argument(i+1))) then
						nom_fichier_routes := To_Unbounded_String(Argument(i+1));
					else
						Put_Line("Erreur nom fichier, doit etre .txt. Choix par defaut table.txt");
					end if;
				when 'p' =>
					if fct_in_directory( To_Unbounded_String(Argument(i+1))) then
						nom_fichier_paquets := To_Unbounded_String(Argument(i+1));
					else
						Put_Line("Erreur nom fichier, doit etre .txt. Choix par defaut paquets.txt ");
					end if;
				when 'r' =>
					if fct_in_directory( To_Unbounded_String(Argument(i+1))) then
						nom_fichier_resultats := To_Unbounded_String(Argument(i+1));
					else
						Put_Line("Erreur nom fichier, doit etre .txt. Choix par defaut resultats.txt");
					end if;
				when others => Put_Line("Commande introuvable, commande disponible : c,P,S,s,t,p,r;");
			end case;
		end if;
	end loop;

   -----------------------------------------------------------------------------
   --------- Enregistrement du fichier d'entrée table.txt dans une LCA----------

   	Open (Entree, In_File, To_String (nom_fichier_routes));

   	Initialiser(table_hach);

   	loop
      		destination_tb := (0,0,0,0);
     		masque_tb := (0,0,0,0);
      		Ligne := Get_Line (Entree);
      		Nb_caractere := Length(Ligne);
      		Trim (Ligne, Both);
		l:=1;
      		m := 1;
      		i := 1;

     		while To_String(Ligne)(i) /= ' ' loop
         		if To_String( Ligne)(i) = '.' then
            			destination := To_Unbounded_String(To_String( Ligne)(m..i-1));
            			destination_tb(l) := Integer'Value (To_String(destination));
            			l := l +1;
            			i := i+1;
            			m := i;
        		end if;
         		i := i +1;
      		end loop;

      		destination := To_Unbounded_String(To_String( Ligne)(m..i-1));
      		destination_tb(4) := Integer'Value (To_String(destination));
      		i := i + 1;
      		table_elt.destination := destination_tb;
      		m := i;
      		l:=1;

      		while To_String(Ligne)(i) /= ' ' loop
         		if To_String( Ligne)(i) = '.' then
            			masque := To_Unbounded_String(To_String( Ligne)(m..i-1));
            			masque_tb(l) := Integer'Value (To_String(masque));
            			l := l +1;
            			i := i+1;
            			m := i;
        		end if;
         		i := i +1;
      		end loop;

      		masque := To_Unbounded_String(To_String( Ligne)(m..i-1));
      		masque_tb(4) := Integer'Value (To_String(masque));
     		i := i + 1;
      		table_elt.masque := masque_tb;
      		interfac := To_Unbounded_String(To_String( Ligne)(i..Nb_caractere));
      		interf_tb := interfac;
      		table_elt.Interfac := interf_tb;
      		Enregistrer (table_hach, table_elt,0);
		exit when End_Of_File (Entree);
	end loop;

   	Close(Entree);

   -----------------------------------------------------------------------------
   ---------- Répéter sur le nombre de ligne du fichier paquets-----------------

   	Create (Sortie, Out_File, To_String (nom_fichier_resultats));

   	Open (Paquets, In_File, To_String(nom_fichier_paquets));

   	Initialiser(resultat_lca);
	prc_Initialiser(cache);
	defaut_cache :=0.0;
   nb_demande :=0.0;




  	loop
      		Ligne := Get_Line (Paquets);
     		Nb_caractere := Length(Ligne);
      		Trim (Ligne, Both);

		-- Traitement d'une adresse
     		if To_String( Ligne)(1) in '0'..'9' then
			table_elt.masque := (0,0,0,0);
         		table_elt.Interfac :=To_Unbounded_String("0");
         		destination := To_Unbounded_String(To_String( Ligne));
         		l:=1;
         		m := 1;

         		for i in 1..4 loop
            			while (To_String( Ligne)(l) /= '.' and l < Nb_caractere) loop
              				l := l +1;
            			end loop;

            		if l = Nb_caractere then
               			destination := To_Unbounded_String(To_String( Ligne)(m..l));
            		else
               			destination := To_Unbounded_String(To_String( Ligne)(m..l-1));
            		end if;

            		destination_tb(i) := Integer'Value (To_String(destination));
            		l := l+1;
           		m := l;

         		end loop;

         		table_elt.destination := destination_tb;


         -----------------------------------------------------------------------
         --------------------------Traitement des paquets ----------------------

	 --On choisit d'afficher la destination ainsi que l'interface

         nb_demande := nb_demande + 1.0;
         Compteur := compteur + 1;

         -- Traitement du paquet en fonction de la table de routage
         taille_m := 0;
         aux_table_hach := table_hach;
         aux_cache := cache;
         indice_cache := 0;
         rep := False;

         if not (borne=0) then
            -- Ici nous devons rajouter la recherche dans le cache
            prc_Rechercher(cache,destination_tb,route_cache,rep,Compteur);
            if rep then
               table_elt.Interfac := route_cache.Interfac;
               taille_m := fct_taille_masque(fct_convertir_10_2_adresse(route_cache.Masque));
            end if ;
         end if;



         if not(rep) then
            aux_table_hach := table_hach;
            defaut_cache := defaut_cache+1.0;
            while (not Est_Vide(aux_table_hach)) loop
               if fct_comp(aux_table_hach.element,destination_tb) and taille_m <= fct_taille_masque(fct_convertir_10_2_adresse(aux_table_hach.element.masque)) then
                  interf := aux_table_hach.element.Interfac;
                  taille_m := fct_taille_masque(fct_convertir_10_2_adresse(aux_table_hach.element.masque));
                  new_masque := fct_new_masque(aux_table_hach.element, aux_table_hach);
               else
                  null;

               end if;
               aux_table_hach := aux_table_hach.suivant;
            end loop;
         else
            null;

         end if;

         taille_m := fct_taille_masque(fct_convertir_10_2_adresse(new_masque));

			if not(taille_m=0) then

				table_elt.masque := new_masque;
            table_elt.Interfac := interf;

            table_elt.Destination := fct_convertir_2_10_adresse(fct_masque_bin(fct_convertir_10_2_adresse(table_elt.Destination),fct_convertir_10_2_adresse(table_elt.Masque)));

				prc_Ajouter(cache,table_elt,Compteur);

			end if;

         		reponse := To_Unbounded_String(To_String(Ligne)) & " " & interf;
         --Put("Destination & interface : " & reponse);

         --New_Line;
         --New_Line;

         -- Ecriture dans le fichier résultat
         Put (Sortie, reponse);
         New_Line (Sortie);



      else



         -- Traitement d'une commande
         if Ligne = "table" then

            prc_Afficher_txt(nom_fichier_routes);

         elsif Ligne = "stat" then
            taux_defaut := defaut_cache/nb_demande;

            Put_Line("Politique : " &politique);
            Put("Défaut du cache :");
            Put(fct_arrondi(defaut_cache));
            New_Line;
            Put("Nombre de demande : ");
            Put(fct_arrondi(nb_demande));
            --Put(Integer'Image(Compteur));
            New_Line;
            Put("Taux de défaut du cache" &Float'Image(taux_defaut));
            New_Line;
            New_Line;
         elsif Ligne = "fin" then
            Fini := True;
         elsif Ligne = "cache" then
            Put_Line("------------- Cache -------------");
            prc_AfficherCache(cache);
            Put_Line("---------------------------------");
            New_Line;
            Put_Line("Politique : " &politique);
            New_Line;
         else
            Null;
         end if;

		end if;
		exit when (End_Of_File (Paquets)) or Fini;

	end loop;

	Close(Paquets);
  	Close (Sortie);
	taux_defaut := defaut_cache/nb_demande;


	if statistique then
		Put("Défaut du cache :");
		Put(fct_arrondi(defaut_cache));
		New_Line;
		Put("Nombre de demande : ");
      Put(fct_arrondi(nb_demande));
		New_Line;
		Put("Taux de défaut du cache" &Float'Image(taux_defaut));
		New_Line;
	end if;

	-- Récupérer l'heure (heure de fin)
	Fin := Clock;

	-- Calculer la durée de l'opération
	Duree := Fin - Debut;

	-- Afficher la durée de l'opération
	Put_Line ("Duree :" & Duration'Image(Duree) & " s");


	exception
	when E : others =>
		Put_Line (Exception_Message (E));

end routeur_La;
