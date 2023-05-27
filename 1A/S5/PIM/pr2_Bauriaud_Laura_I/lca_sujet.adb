-- définir les généricités pour pouvoir utiliser lca.ads
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Integer_Text_IO;       use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO; use  Ada.Text_IO.Unbounded_IO;
with SDA_Exceptions; 		use SDA_Exceptions;
with lca;

procedure Lca_Sujet is 

	package Lca_String_Integer is
		new lca (T_Cle => Unbounded_String, T_Donnee => Integer);
	use Lca_String_Integer;

	function Avec_Guillemets (S: Unbounded_String) return String is
	begin
		return '"' & To_String (S) & '"';
	end;

	-- Utiliser & entre String à gauche et Unbounded_String à droite.  Des
	-- guillemets sont ajoutées autour de la Unbounded_String 
	-- Il s'agit d'un masquage de l'opérateur `&` défini dans Strings.Unbounded
	function "&" (Left: String; Right: Unbounded_String) return String is
	begin
		return Left & Avec_Guillemets (Right);
	end;


	-- Surcharge l'opérateur unaire "+" pour convertir une String
	-- en Unbounded_String.
	-- Cette astuce permet de simplifier l'initialisation
	-- de cles un peu plus loin.
	function "+" (Item : in String) return Unbounded_String
		renames To_Unbounded_String;

		
	-- Afficher une Unbounded_String et un entier.
	procedure Afficher (S : in Unbounded_String; N: in Integer) is
	begin
		Put (Avec_Guillemets (S));
		Put (" : ");
		Put (N, 1);
		New_Line;
	end Afficher;

	-- Afficher la Sda.
	procedure Afficher is
		new Pour_Chaque (Afficher);

	Lca:T_LCA;
	
	S1 : Unbounded_String := To_unbounded_String("un");
	S2 : Unbounded_String := To_unbounded_String("deux");

begin
	Initialiser(Lca);
	Enregistrer(Lca,S1,1);
	Enregistrer(Lca,S2,2);
	Afficher(Lca);

end Lca_sujet;
