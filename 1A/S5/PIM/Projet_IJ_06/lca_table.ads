--Définition du type lca_table

generic
	
	type T_element is private;

package lca_table is

	type T_Cellule;

	type T_LCA is access T_Cellule;

	Type T_Cellule is
		record
         		Element : T_element;
         		Frequence : Integer; -- Uniquement pour LFU
        		Suivant : T_LCA;
		end record;	

	-- Initialiser une Sda.  La Sda est vide.
	procedure Initialiser(Sda: out T_LCA);

	--Savoir si une Sda est vide
	function Est_Vide (Sda : T_LCA) return boolean;
	
	--Enregistrer un élément dans une Sda, en queue
	procedure Enregistrer (Sda : in out T_LCA ; element : in T_element; frequence : in Integer);

	-- Donner la taille de la Sda
	function fct_taille (Sda : in T_LCA) return integer;

	--DÃ©placer une donnÃ©e en place i d'une Sda Ã  la fin
	procedure prc_deplacer_i_fin (Sda : in out T_LCA; i : in out integer);

	-- Supprimer le premier Ã©lÃ©ment d'une Sda
   	procedure prc_supprimer (Sda : in out T_LCA);

	-- Supprimer le dernier élément d'une Sda
	procedure prc_supprimer_dernier (Sda : in out T_LCA);
  
  	-- Supprimer l'élément avec la fréquence la plus faible
   	procedure prc_supprimer_LFU(Sda : in out T_LCA);
	
	-- Supprimer tous les Ã©lÃ©ments d'une Sda.
	procedure Vider (Sda : in out T_LCA);

	--Renvoie la fréquence d'un élément.
	function fct_freq(Sda : in T_LCA) return integer;

	-- Appliquer un traitement (Traiter) pour chaque couple d'une Sda.
	generic
		with procedure Traiter (element : in out T_element);
	procedure Pour_Chaque (Sda : in T_LCA);

		

-- 3 types d'éléments en fonction de table, résultat ou paquet

end LCA_table;
