with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Integer_Text_IO;   use Ada.Integer_Text_IO;
with Ada.Calendar;          use Ada.Calendar;

procedure Mesure_Temps is
	N: Integer;          -- un entier lu au clavier
	Debut: Time;         -- heure de début de l'opération
	Fin: Time;           -- heure de fin de l'opération
	Duree : Duration;    -- durée de l'opération
	aux : float;
begin
	-- récupérer l'heure (heure de début)
	Debut := Clock;	

	-- réaliser l'opération
	Put_Line ("Début");
	Put ("Valeur : ");
	Get (N);
	Put_Line ("Fin");

	-- récupérer l'heure (heure de fin)
	Fin := Clock;

	-- calculer la durée de l'opération
	Duree := Fin - Debut;

	-- Afficher la durée de opération
	Put_Line ("Durée :" & Duration'Image(Duree));

	-- Initialisation directe
	Duree := Duration (0.5);
	Put_Line ("Durée = " & Duration'Image(Duree));

	Duree := Duree + Duration (1);
	Put(Duration'Image(Duree));

	Duree := Duree / 10.0;
	Put(Duration'Image(Duree));

end Mesure_Temps;
