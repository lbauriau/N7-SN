package allumettes;
import java.util.Random;

public class StrategieNaif implements Strategie {
    /** Nous définissons la stratégie naif telle que :
     * le joueur prend un nombre aléatoire d'allumettes
     */
	private static Random random;

	public StrategieNaif() {
		random = new Random();
	}

    public int getPrise(Jeu jeu, Joueur joueur) {
        int nbAllumetteNaif = jeu.getNombreAllumettes();
        if (nbAllumetteNaif < Jeu.PRISE_MAX) {
            return random.nextInt(nbAllumetteNaif) + 1;
        } else {
            return random.nextInt(Jeu.PRISE_MAX) + 1;
        }
    }
}
