with types ; use types;


package convert is
   type T_bin_8 is array (1..8) of Integer;
	type T_adresse_bin is array (1..4) of T_bin_8;
   type T_AdresseIP2 is array(1..32) of Integer;

   function fct_12(adresse : in T_AdresseIP) return T_AdresseIP2;

   function fct_21(adresse : in T_AdresseIP2) return T_AdresseIP;

   function fct_test1(adresse1 : in T_AdresseIP ; adresse2 : in T_AdresseIP) return Boolean;

   function fct_test2(adresse1 : in T_AdresseIP2 ; adresse2 : in T_AdresseIP2) return Boolean;

   function fct_egalite(adresse : T_adresse_bin; masque : T_adresse_bin) return boolean;

   function fct_masque_bin (adresse : T_adresse_bin; masque : T_adresse_bin) return T_adresse_bin;

   function fct_et_bin (elt : T_bin_8; elt_masque : T_bin_8) return T_bin_8;

   function fct_convertir_2_10_adresse ( adresse_bin : T_adresse_bin) return T_adresseIP;

   function fct_convertir_2_10 (tab_2 : T_bin_8) return Integer;

   function fct_convertir_10_2_adresse ( adresse : T_adresseIP) return T_adresse_bin ;

   function fct_convertir_10_2 ( entier_10 : integer) return T_bin_8;


end convert;
