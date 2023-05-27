package allumettes;

public class StrategieTricheur implements Strategie {
	/** Nous définissons la stratégie tricheur telle que :
	 * il reste deux allumettes en jeu lorque c'est au tour du joueur,
	 * il en prend une et gagne.
	 */
    @Override
    public int getPrise(Jeu jeu, Joueur joueur) {
    	try {
    		int nbAllumette = jeu.getNombreAllumettes();
    		System.out.println("[Je triche...]");
    		jeu.retirerTriche();
    	} catch (CoupInvalideException e) {
    	}
    	System.out.println("[Allumettes restantes : " + jeu.getNombreAllumettes() + "]");
    	return 1;
    }
}
