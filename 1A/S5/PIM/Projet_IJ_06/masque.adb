-- Function qui prend en entré un masque et renvoie un nouveau masque, on a ajouté un 1 au masque
-- Le masque d'entrée n'est pas en binaire

function fct_new_masque (masque : T_adresse_IP) return T_adresse_IP is
	masque_bin : T_adresse_bin;
	i : integer;
	j : integer;
	b : bool;
	new_masque : T_adresse_IP;
begin
	masque_bin := fct_convertir_10_2_adresse(masque);
	b := true;
	i := 1;
	j := 1;
	while b and (j<=4) loop
		while b and (i<=8) loop
			if masque_bin(j)(i) = 0 then
				masque_bin(j)(i) := 1;
				b := false;
			else
				i := i+1;
			end if;
		end loop;
		j := j+1;
		i := 1;
	end loop;
	new_masque := fct_convertir_2_10_adresse(masque_bin);
	return new_masque;
end fct_new_masque;
