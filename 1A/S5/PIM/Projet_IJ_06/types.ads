with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Unchecked_Deallocation;

package types is

   borne : Integer;
   politique : Unbounded_String;
   rep : Boolean;


   type T_AdresseIP is array(1..4) of Integer;
   --type T_Masque is array(1..4) of Integer;
   type T_Routes is
      record
         Destination : T_AdresseIP;
         Masque : T_AdresseIP ;
         Interfac : Unbounded_String ;
      end record;

   type T_Noeud;
   type T_Cache_LA is access T_Noeud;
   type T_Noeud is
      record
         Fg : T_Cache_LA;
         Route : T_routes ;
         Compteur : Integer;
         Fd : T_Cache_LA ;
      end record;

   



   procedure free is new ada.Unchecked_Deallocation(Object => T_Noeud,
                                          Name   => T_Cache_LA);





end types;
