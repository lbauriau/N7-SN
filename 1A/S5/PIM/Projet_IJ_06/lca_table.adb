with Ada.Unchecked_Deallocation;

--Corps de lca_table

package body lca_table is

	procedure Free is
		new Ada.Unchecked_Deallocation (Object => T_Cellule, Name => T_LCA);


	procedure Initialiser(Sda: out T_LCA) is
	begin
		Sda := Null;	
	end Initialiser;

	function Est_Vide ( Sda : T_LCA) return boolean is
	begin
		return Sda = null;
	end Est_Vide;


	procedure Enregistrer (Sda : in out T_LCA ; element : in T_element; frequence : in Integer) is
	begin
		if Sda= null then
			Sda := new T_Cellule'(element, frequence, Sda);
		else
			Enregistrer (Sda.All.Suivant, element, frequence);
		end if;
	end Enregistrer;

	function fct_taille (Sda : in T_LCA) return integer is
		i : integer:= 0;
		Sda_aux : T_LCA;
	begin
		Sda_aux := Sda;
		while not (Sda_aux = Null) loop
			i := i +1;
			Sda_aux := Sda_aux.suivant;
		end loop;
		return i;
	end fct_taille;

	procedure prc_deplacer_i_fin(Sda : in out T_LCA; i : in out integer) is
	begin
		if i=1 then
			Enregistrer(Sda, Sda.All.element, Sda.All.Frequence);
			prc_supprimer(Sda);
		else
			i := i-1;
			prc_deplacer_i_fin(Sda.All.suivant, i);
		end if;
	end prc_deplacer_i_fin;

	procedure prc_supprimer (Sda : in out T_LCA) is
		aux : T_LCA;
	begin
		if not (Sda = Null) then
			aux := Sda.All.Suivant;
			Free(Sda);
			Sda := aux;
		else
			Free(SdA);
		end if;
	end prc_supprimer;

	procedure prc_supprimer_dernier (Sda : in out T_LCA) is
	begin
		if (Sda.All.Suivant = Null) then
			Free(Sda);
		else
			prc_supprimer_dernier(Sda.All.suivant);
		end if;
	end prc_supprimer_dernier;


   procedure prc_supprimer_LFU (Sda : in out T_LCA) is
      aux : T_LCA := Sda;
      min : Integer := Sda.Frequence;
      indice : integer := 0;
      indice_min : integer := 1;
   begin
         -- recherche fréquence min
         while aux.Suivant /= null loop
		 indice := indice+1;
		 if aux.Frequence < min then
			 min := aux.Frequence;
			 indice_min := indice;
		 else
			 null;
		 end if;
		 aux := aux.Suivant;
         end loop;
         
         prc_deplacer_i_fin(Sda, indice_min);
	prc_supprimer_dernier(Sda);	
   end prc_supprimer_LFU;

	procedure Vider (Sda : in out T_LCA) is
	begin
		if Sda = null then
			Null;
		else
			Vider(Sda.All.Suivant);
			Free(Sda);
		end if;
	end Vider;

	function fct_freq(Sda : in T_LCA) return Integer is
	begin
		return Sda.All.Frequence;
	end fct_freq;


	procedure Pour_Chaque (Sda : in T_LCA) is
	begin
		if Sda = null then
			Null;
		elsif not Est_vide(Sda) then
			Traiter(Sda.All.element);
			Pour_Chaque(Sda.All.Suivant);
		else
			Traiter(Sda.All.element);
		end if;

	Exception when others  => Pour_Chaque(Sda.All.Suivant);
	

	end Pour_Chaque;




end lca_table;
