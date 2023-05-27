with Ada.Text_IO.Unbounded_IO;  use Ada.Text_IO.Unbounded_IO;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Text_IO;               use Ada.Text_IO;

with convert ; use convert;



package body Cache_LA is
   procedure prc_Initialiser(cache : out T_Cache_LA) is
   begin
      cache := null;
   end prc_Initialiser;


   function fct_EstVide(cache : in T_Cache_LA) return Boolean is
   begin
      return cache = null;
   end fct_EstVide;




   procedure prc_Ajouter(cache : in out T_Cache_LA ; route : in T_Routes; Compteur : in Integer) is

      a1 :  constant T_AdresseIP2 := fct_12(route.Destination);
      k :Integer;
      comp : Integer;
      procedure aux(cache : in out T_Cache_LA; route : in T_Routes; adresse : in T_AdresseIP2; k : in out Integer ; Compteur : in Integer) is
         a2 :  T_AdresseIP2;
      begin

         if fct_EstVide(cache) then
            if politique = To_Unbounded_String("FIFO") then
               comp := Compteur;
            elsif politique = To_Unbounded_String("LRU") then
               comp := Compteur;
            elsif politique = To_Unbounded_String("LFU") then
               comp := 1;
            else
               null;
            end if;
            cache := new T_Noeud'(null,route,comp,null);
              
         elsif cache.all.Fg=null and cache.all.Fd=null then
            a2 := fct_12(cache.all.Route.Destination);
            if a2(k)=1 then
               cache.all.Fd := new T_Noeud'(null,cache.all.Route,cache.all.Compteur,null);
               aux(cache, route, adresse, k,Compteur);
            else
               cache.all.Fg := new T_Noeud'(null,cache.all.Route,cache.all.Compteur,null);
               aux(cache, route, adresse, k,Compteur);
            end if;
         else
            if adresse(k)=1 then
               k:= k+1;
               aux(cache.all.Fd, route,adresse,k,Compteur);
            else
               k:=k+1;
               aux(cache.all.Fg, route,adresse,k,Compteur);
            end if;
         end if;
      end aux;
   begin
      if fct_Appartient(cache, route) then
          null;
      else

         k :=1;
         aux(cache,route,a1,k,Compteur);
      end if;

   end prc_Ajouter;

   procedure prc_Rechercher(cache : in out T_Cache_LA; adresse : in T_AdresseIP ; route : in out T_Routes; rep : in out Boolean; Compteur : in Integer) is
      a1 : constant T_AdresseIP2 := fct_12(adresse);
      k: Integer :=1;
      comp : Integer;
      procedure aux(cache : in T_Cache_LA; adresse : in T_AdresseIP2; k : in out Integer; Compteur : in Integer)  is
      begin
         if cache = null then
            rep:= false;
         elsif cache.all.Fg=null and cache.all.Fd=null then
            if fct_convertir_2_10_adresse(fct_masque_bin(fct_convertir_10_2_adresse(fct_21(adresse)),fct_convertir_10_2_adresse(cache.all.Route.Masque)))=cache.all.Route.Destination then
               route := cache.all.Route;
               if politique = To_Unbounded_String("LRU") then
                  comp := Compteur;
               elsif politique = To_Unbounded_String("LFU") then
                  comp := cache.all.Compteur +1;
               else
                  null;
               end if;
               cache.all.Compteur:= Compteur;
               rep := True;
            end if;
         else
            rep := False;
            if adresse(k) =1 then
               k := k+1;
                aux(cache.all.Fd, adresse, k,Compteur);
            else
               k:=k+1;
                aux(cache.All.Fg,adresse,k,Compteur);
            end if;
         end if;
      end aux;
   begin
       aux(cache,a1,k,Compteur);
   end prc_Rechercher;






   function fct_Taille(cache : in T_Cache_LA) return Integer is
   begin
      if fct_EstVide(cache) then
         return 0;
      elsif cache.all.Fg =null and cache.all.Fd =null then
        return 1;
      else
         return fct_Taille(cache.all.Fg) + fct_Taille(cache.all.Fd);
      end if ;
   end fct_Taille;



   function fct_Appartient(cache : in T_Cache_LA ; route : in T_Routes) return Boolean is
      a1 : Constant  T_AdresseIP2 := fct_12(route.Destination);
      i : Integer := 1;

      function aux(cache : in T_Cache_LA ; adresse : in T_AdresseIP2 ; k : in out Integer) return Boolean is
      begin
         if cache = null then
            return False;
         elsif cache.all.Fg =null and cache.all.Fd =null then
            return cache.all.Route.Destination = route.Destination;
         else
            if a1(k)=0 then
               k := k+1;
               return aux(cache.all.Fg,adresse,k);
            else
               k := k+1;
               return aux(cache.all.Fd,adresse,k);
            end if ;
         end if;
      end aux ;

   begin
      return aux(cache,a1,i);
   end fct_Appartient;



   function fct_ASupprimer(cache : in T_Cache_LA ) return T_Routes is
      ancienne_route : T_Routes;
      comp : Integer;
      procedure aux(cache : in T_Cache_LA) is
      begin
         if cache = null then
            null;
         elsif cache.all.Fg=null and cache.all.Fd=null and cache.all.Compteur < comp then
            ancienne_route := cache.all.Route;
            comp := cache.all.Compteur;
         elsif (cache.all.Fg=null) and (cache.all.Fd=null) and not(cache.all.Compteur < comp) then
            null;
         else
            aux(cache.all.Fg);
            aux(cache.all.Fd);
         end if;
      end aux;
   begin
      aux(cache);
      return ancienne_route;
   end fct_ASupprimer;




   procedure prc_Supprimer(cache : in out T_Cache_LA ; ancienne_route : in T_Routes) is
      a2 : constant T_AdresseIP2 := fct_12(ancienne_route.Destination);
      i : Integer := 1;

      procedure remonter(cache : in out T_Cache_LA) is
         aux : T_Cache_LA;
      begin
         if cache =null then
            null;
         else


            if cache.all.Fg=null and cache.all.Fd = null then
               null;
            elsif cache.all.Fg /= null and cache.all.Fd /= null then
               null;
            else
               if cache.all.Fg /= null then
                  if cache.all.Fg.all.Fg=null and cache.all.Fg.all.Fd=null then
                     aux := cache.all.Fg;
                     free(cache);
                     cache := aux;
                  end if;
               else
                  if cache.all.Fd.all.Fg=null and cache.all.Fd.all.Fd=null then
                     aux := cache.all.Fd;
                     free(cache);
                     cache := aux;
                  end if;
               end if;
            end if;
         end if;

      end remonter;
      procedure aux_sup(cache : in out T_Cache_LA;adresse : T_AdresseIP2 ; k: in out Integer) is
      begin
         if cache.all.Fg=null and cache.all.Fd = null then
            free(cache);
            cache := null;
         else

            if adresse(k) =1 then
               k := k+1;
               aux_sup(cache.all.Fd,adresse, k);
               remonter(cache);
            else
               k := k+1;
               aux_sup(cache.all.Fg,adresse, k);
               remonter(cache);
            end if;
         end if;
      end aux_sup;
   begin
      aux_sup(cache,a2,i);
   end prc_Supprimer;





   procedure prc_AfficherCache(cache : T_Cache_LA) is

	begin
      if fct_EstVide(cache) then
         --Put ("...");
         null;
      elsif cache.all.Fg =null and cache.all.Fd =null then
         for I in 1..3 loop
        	 		Put(Integer'Image(Cache.all.Route.Destination(I)));
				Put(".");
     		 	end loop;
			Put(Integer'Image(Cache.all.Route.Destination(4)));
			Put(" ");
      			for I in 1..3 loop
         			Put(Integer'Image(Cache.all.Route.Masque(I)));
				Put(".");
         end loop;

         Put(Integer'Image(Cache.all.Route.Masque(4)));

			Put(" ");
         Put(cache.all.Route.Interfac);
         --Put(Integer'Image(Cache.all.Compteur));
         New_Line;
         --Put("/");
         --prc_AfficherCache(cache.all.Fg);
        -- New_Line;
         --Put("\");
         --prc_AfficherCache(cache.all.Fd);
      else
         --Put("/");
         prc_AfficherCache(cache.all.Fg);
         --New_Line;
         --Put("\");
         prc_AfficherCache(cache.all.Fd);
      end if;

   end prc_AfficherCache;

end Cache_LA;
