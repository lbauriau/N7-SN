-- with Ada.Text_IO;            use Ada.Text_IO;
with SDA_Exceptions;         use SDA_Exceptions;
with Ada.Unchecked_Deallocation;

package body LCA is

	procedure Free is
		new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_LCA);


	procedure Initialiser(Sda: out T_LCA) is
	begin
		Sda := Null;	
	end Initialiser;


	function Est_Vide (Sda : T_LCA) return Boolean is
	begin
		return Sda = Null;	
	end Est_Vide;


	function Taille (Sda : in T_LCA) return Integer is
	begin
		if Sda = null then
			return 0;
		else
			return Taille (Sda.All.Suivant) + 1;
		end if;
	end Taille;


	procedure Enregistrer (Sda : in out T_LCA ; Cle : in T_Cle ; Donnee : in T_Donnee) is
	begin
		if Sda= null then
			Sda := new T_Cellule'(Cle,Donnee,Sda);
		elsif Sda.All.Cle = Cle then
			Sda.All.Donnee := Donnee;
		else
			Enregistrer (Sda.All.Suivant, Cle, Donnee);
		end if;
	end Enregistrer;


	function Cle_Presente (Sda : in T_LCA ; Cle : in T_Cle) return Boolean is
	begin
		if Sda = null then
			return false;
		elsif Sda.All.Cle = Cle then
			return true;
		else
			return(Cle_Presente(Sda.All.Suivant, Cle));
		end if;
	end Cle_Presente;


	function La_Donnee (Sda : in T_LCA ; Cle : in T_Cle) return T_Donnee is
	begin
		if Sda = NUll then
			raise Cle_Absente_Exception;
		elsif Sda.All.Cle = Cle then
			return(Sda.All.Donnee);
		else
			return(La_Donnee(Sda.All.Suivant, Cle));
		end if;
	end La_Donnee;


	procedure Supprimer (Sda : in out T_LCA ; Cle : in T_Cle) is
		A_Supprimer : T_LCA;
	begin
		if Sda = null then
			raise Cle_Absente_Exception;
		elsif Sda.All.Cle = Cle then
			A_Supprimer := Sda;
			Sda := Sda.All.Suivant;
			Free(A_Supprimer);
		else
			Supprimer(Sda.All.Suivant, Cle);
		end if;
			
	end Supprimer;

	procedure Vider (Sda : in out T_LCA) is
	begin
		if Sda = null then
			Null;
		else
			Vider(Sda.All.Suivant);
			Free(Sda);
		end if;
	end Vider;


	procedure Pour_Chaque (Sda : in T_LCA) is
	begin
		if Sda = null then
			Null;
		elsif not Est_vide(Sda) then
			Traiter(Sda.All.Cle, Sda.All.Donnee);
			Pour_Chaque(Sda.All.Suivant);
		else
			Traiter(Sda.All.Cle, Sda.All.Donnee);
		end if;

	Exception when others  => Pour_Chaque(Sda.All.Suivant);
	

	end Pour_Chaque;

end LCA;
