with Ada.Text_IO;            use Ada.Text_IO;
with SDA_Exceptions;         use SDA_Exceptions;
with Ada.Unchecked_Deallocation;

package body Th is

	procedure Initialiser_th(Th : out T_th) is
	begin
		for k in 1..Capacite loop
			Initialiser(Th(k));
		end loop;
	end Initialiser_th;


	function Est_Vide_th (Th : T_th) return Boolean is
		b : Boolean;
		k : Integer;
	begin
		k:=1;
		loop
			b := Est_Vide(Th(k));
			k := k+1;
			exit when (not b and k>Capacite);
		end loop;
		return b;
	end Est_Vide_th;


	function Taille_Th (Th : in T_th) return Integer is
		Somme : Integer;
	begin
		Somme :=0;
		for k in 1..Capacite loop
			Somme := Somme +Taille(Th(k));
		end loop;
		return Somme;
	end Taille_Th;


	procedure Enregistrer_Th (Th: in out T_th ; Cle : in T_Cle ; Donnee : in T_Donnee) is
		indice : integer;
	begin
		indice:=F_hachage(Cle);
		Enregistrer(Th(indice),Cle,Donnee);
	end Enregistrer_Th;

	
	procedure Supprimer_th (Th : in out T_Th ; Cle : in T_Cle) is
		indice : integer;
	begin
		indice:=F_hachage(Cle);
		Supprimer(Th(indice),Cle);
	end Supprimer_th;


	function Cle_presente_Th (Th : in T_th ; Cle : in T_Cle) return Boolean is
		indice : integer;
	begin
		indice:=F_hachage(Cle);
		return Cle_presente(Th(indice),Cle);
	end Cle_presente_Th;


	function La_Donnee_Th (Th: in T_th ; Cle : in T_Cle) return T_Donnee is
		indice : integer;
	begin
		indice:=F_hachage(Cle);
		return La_Donnee(Th(indice),Cle);
	end La_Donnee_Th;

	
	procedure Vider_Th (Th : in out T_th) is
	begin
		for k in 1..Capacite loop
			Vider(Th(k));
		end loop;
	end Vider_Th;


	procedure Pour_Chaque (Th : in T_Th) is

		procedure Pour_Chaque is new LCA_th.Pour_Chaque(Traiter);

	begin
		for k in 1..Capacite loop
			Pour_Chaque(Th(k));
		end loop;
	end Pour_Chaque;


end Th;
