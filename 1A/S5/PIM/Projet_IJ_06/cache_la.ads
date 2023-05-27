with types ; use types;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;


package Cache_LA is
   Route_deja_presente : exception;


   -- Initialise un cache_la vide
   procedure prc_Initialiser(cache : out T_Cache_LA) with
     Post => fct_Estvide(cache);


   --test si un cache_la est vide
   function fct_EstVide(cache : in T_Cache_LA) return Boolean;


   -- procedure qui ajoute un element au cache_la (bon compteur compris)
   procedure prc_Ajouter(cache : in out T_Cache_LA ; route : in T_Routes ; Compteur : in Integer) with
     Pre => not(fct_Appartient(cache,route)),
     Post => fct_Taille(cache) >= fct_Taille(cache)'Old;


   -- donne la taille d'un cache_LA
   function fct_Taille(cache : in T_Cache_LA) return Integer;


   --determine si une route donnée appartient au cache
   function fct_Appartient(cache : in T_Cache_LA; route : in T_Routes) return Boolean;


   --determine la route dont le compteur est le plus faible (route à supprimer du cache)
   function fct_ASupprimer(cache : in T_Cache_LA) return T_Routes with
   Pre => not(fct_EstVide(cache));


   --supprime un élément donné du cache
   procedure prc_Supprimer(cache : in out T_Cache_LA ; ancienne_route : in T_Routes)with
     Pre => fct_Taille(cache) >=1 and then fct_Appartient(cache,ancienne_route),
     Post => fct_Taille(cache) = fct_Taille(cache)'Old -1;

   --chercher une réponse à la requête dans le cache et met à jour son compteur son elle la trouve
   procedure prc_Rechercher(cache : in out T_Cache_LA; adresse : in T_AdresseIP;route : in out T_Routes; rep : in out Boolean; Compteur : in Integer) with
     Pre => not(fct_EstVide(cache));


   --afficher tous les éléments du cache
   procedure prc_AfficherCache(cache : in T_Cache_LA);


end Cache_LA;
