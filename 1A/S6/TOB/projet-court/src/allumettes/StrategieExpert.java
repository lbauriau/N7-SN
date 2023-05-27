package allumettes;

public class StrategieExpert implements Strategie {
    /** Nous définissons la stratégie expert telle que :
     * le joueur soit sûr de gagner.
     */
    @Override
    public int getPrise(Jeu jeu, Joueur joueur) {
        int nbAllumette = jeu.getNombreAllumettes();
        if (nbAllumette == 1) {
        	return nbAllumette;
        } else {
        	int reste = (nbAllumette - 1) % (Jeu.PRISE_MAX + 1);
        	if (reste == 0) {
        		return Math.min(Jeu.PRISE_MAX, nbAllumette - 1);
        	} else {
        		return reste;
        	}
        }
    }
}
