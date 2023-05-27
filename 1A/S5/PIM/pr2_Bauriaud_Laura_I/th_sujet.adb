with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Integer_Text_IO;   use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with SDA_Exceptions;	    use SDA_Exceptions;
with th;

procedure th_sujet is

	Capa : constant Integer := 11;

	function hachage (Cle : in Unbounded_String) return Integer is
		indice : Integer;
	begin
		indice := (length(Cle)-1) mod Capa + 1;
		return indice;
	end hachage;


	package Th_String_Integer is
		new Th (T_Cle => Unbounded_String, T_Donnee => Integer, Capacite => Capa, F_hachage => hachage);
	use Th_String_Integer;


	-- Retourner une chaîne avec des guillemets autour de S
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

	-- Afficher la Th.
	procedure Afficher is
		new Pour_Chaque (Afficher);

	Th : T_Th;

begin

	Initialiser_Th (Th);

	pragma Assert (Est_Vide_Th (Th));

	Enregistrer_Th(Th, To_Unbounded_String ("un"), 1);
	Enregistrer_Th(Th, To_Unbounded_String ("deux"), 2);
	Enregistrer_Th(Th, To_Unbounded_String ("trois"), 3);
	Enregistrer_Th(Th, To_Unbounded_String ("quatre"), 4);
	Enregistrer_Th(Th, To_Unbounded_String ("cinq"), 5);
	Enregistrer_Th(Th, To_Unbounded_String ("quatre-vingt-dix-neuf"), 99);
	Enregistrer_Th(Th, To_Unbounded_String ("vingt-et-un"), 21);

	Afficher(Th);

	Vider_Th(Th);

end th_sujet;

