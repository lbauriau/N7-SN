-- Définition de structures de données associatives sous forme d'une table de hachage (Th)

with LCA;

generic 
	type T_Cle is private;
	type T_Donnee is private;
	Capacite : Integer;
	with function F_hachage (Cle : in T_Cle) return Integer;


package th is

	type T_th is limited private;

	-- Initialiser une Th.  
	procedure Initialiser_Th (Th: out T_th) with
		Post => Est_Vide_Th (Th);


	-- Est-ce qu'une Th est vide ?
	function Est_Vide_Th (Th :  T_th) return Boolean;


	-- Obtenir le nombre d'éléments d'une Th. 
	function Taille_Th (Th : in T_th) return Integer with
		Post => Taille_Th'Result >= 0
			and (Taille_Th'Result = 0) = Est_Vide_Th (Th);
			

	-- Enregistrer une Donnée associée à une Clé dans une Th.
	-- Si la clé est déjà présente dans la Th, sa donnée est changée.
	procedure Enregistrer_Th (Th : in out T_th ; Cle : in T_Cle ; Donnee : in T_Donnee) with
		Post => Cle_Presente_Th (Th, Cle) and (La_Donnee_Th (Th, Cle) = Donnee)   -- donnée insérée
				and (not (Cle_Presente_Th (Th, Cle)'Old) or Taille_Th (Th) = Taille_Th (Th)'Old)
				and (Cle_Presente_Th (Th, Cle)'Old or Taille_Th (Th) = Taille_Th (Th)'Old + 1);

	-- Supprimer la Donnée associée à une Clé dans une Th.
	-- Exception : Cle_Absente_Exception si Clé n'est pas utilisée dans la Th
	procedure Supprimer_Th (Th : in out T_th ; Cle : in T_Cle) with
		Post =>  Taille_Th (Th) = Taille_Th (Th)'Old - 1 -- un élément de moins
			and not Cle_Presente_Th (Th, Cle);         -- la clé a été supprimée


	-- Savoir si une Clé est présente dans une Th.
	function Cle_Presente_Th (Th : in T_th ; Cle : in T_Cle) return Boolean;


	-- Obtenir la donnée associée à une Cle dans la Th.
	-- Exception : Cle_Absente_Exception si Clé n'est pas utilisée dans la Th
	function La_Donnee_Th (Th : in T_th ; Cle : in T_Cle) return T_Donnee;


	-- Supprimer tous les éléments d'une Th.
	procedure Vider_Th (Th : in out T_th) with
		Post => Est_Vide_Th (Th);


	-- Appliquer un traitement (Traiter) pour chaque couple d'une Sda.
	generic
		with procedure Traiter (Cle : in T_Cle; Donnee: in T_Donnee);
	procedure Pour_Chaque (Th : in T_th);


private

	package LCA_th is
		new LCA (T_Cle => T_Cle, T_Donnee => T_Donnee);
	use LCA_th;

	type T_Th is array (1..Capacite) of LCA_th.T_LCA;
	
	
end Th;
