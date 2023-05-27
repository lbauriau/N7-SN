

package body convert is
   function fct_12(adresse: in T_AdresseIP) return T_AdresseIP2 is
      r : T_AdresseIP2;
      aux :  T_AdresseIP := adresse;

   begin
      for i in 1..4 loop
         for j in 1..8 loop
            r(i*8 - (j-1)):= aux(i) mod 2;
              aux(i) := aux(i)/2;
         end loop;
      end loop;
      return r ;
   end fct_12;



   function fct_21(adresse: in T_AdresseIP2) return T_AdresseIP is
      r : T_AdresseIP := (0,0,0,0);
      aux : constant T_AdresseIP2 := adresse;

   begin
      for i in 1..4 loop
         for j in 1..8 loop
            r(i):= r(i) + aux((i-1)*8 + j)*2**(8-j);
         end loop;
      end loop;
      return r ;
   end fct_21;

   function fct_test1(adresse1 : in T_AdresseIP ; adresse2 : in T_AdresseIP) return Boolean is
   begin

      return adresse1 = adresse2;
   end fct_test1;


   function fct_test2(adresse1 : in T_AdresseIP2 ; adresse2 : in T_AdresseIP2) return Boolean is
       begin

      return adresse1 = adresse2;
   end fct_test2;

   function fct_convertir_10_2 ( entier_10 : integer) return T_bin_8 is
		resultat : T_bin_8;
		quotient : Integer;
		k : Integer;
	begin
		quotient := entier_10 ;
		k :=8;
		while (k>=1) loop
			resultat(k) := quotient mod 2;
			quotient := quotient / 2;
			k := k-1;
		end loop;
		return resultat;
	end fct_convertir_10_2;


	-- Conversion d'une adresse_IP en base 10 en écriture binaire

	function fct_convertir_10_2_adresse ( adresse : T_adresseIP) return T_adresse_bin is
		adresse_bin : T_adresse_bin;
	begin
		for k in 1..4 loop
			adresse_bin(k) := fct_convertir_10_2(adresse(k));
		end loop;
		return adresse_bin;
	end fct_convertir_10_2_adresse;


	--Conversion d'un entier en binaire en écriture décimale

	function fct_convertir_2_10 (tab_2 : T_bin_8) return Integer is
		resultat : Integer;
	begin
		resultat := 0;
		for k in 1..7 loop
			resultat := (resultat + tab_2(k))*2;
		end loop;
		resultat := resultat +tab_2(8);
		return resultat;
	end fct_convertir_2_10;


	-- Conversion d'une adresse_IP en base 2 en écriture décimale

	function fct_convertir_2_10_adresse ( adresse_bin : T_adresse_bin) return T_adresseIP is
		adresse_IP : T_adresseIP;
	begin
		for k in 1..4 loop
			adresse_IP(k) := fct_convertir_2_10(adresse_bin(k));
		end loop;
		return adresse_IP;
	end fct_convertir_2_10_adresse;

	--Fonction qui effectue un & bit à bit (utilisée lors de l'application d'un masque).

	function fct_et_bin (elt : T_bin_8; elt_masque : T_bin_8) return T_bin_8 is
	       elt_final : T_bin_8;
	begin
		for k in 1..8 loop
			if (elt(k)=1) and (elt_masque(k)=1) then
				elt_final(k) := 1;
			else
				elt_final(k) := 0;
			end if;
		end loop;
		return elt_final;
	end fct_et_bin;

	--Fonction qui applique un masque à une adresse

	function fct_masque_bin (adresse : T_adresse_bin; masque : T_adresse_bin) return T_adresse_bin is
		adresse_masquee : T_adresse_bin;
		ad_bin : T_bin_8;
		mas_bin : T_bin_8;
	begin
		for k in 1..4 loop
			ad_bin := adresse(k);
			mas_bin := masque(k);
			adresse_masquee(k) := fct_et_bin(ad_bin,mas_bin);
		end loop;
		return adresse_masquee;
  	end fct_masque_bin;



	--Fonction qui compare deux adresse_IP

	function fct_egalite(adresse : T_adresse_bin; masque : T_adresse_bin) return boolean is
		egal : boolean := true;
		i : integer := 1;
		j : integer := 1;
	begin
		while not (i=5) and egal loop
			egal := adresse(i)(j)=masque(i)(j);
			if j = 8 then
				j:= 1;
				i := i+1;
			else
				j := j+1;
			end if;
		end loop;
		return egal;
	end fct_egalite;



end convert;
