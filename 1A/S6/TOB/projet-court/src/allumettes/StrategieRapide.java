package allumettes;

public class StrategieRapide implements Strategie {
    /** Nous définissons la stratégie rapide telle que :
     * le joueur prend toujours le maximum d'allumettes possibles.
     */
    @Override
    public int getPrise(Jeu jeu, Joueur joueur) {
        int nbAllumetteRapide = jeu.getNombreAllumettes();
        if (nbAllumetteRapide < Jeu.PRISE_MAX) {
            return nbAllumetteRapide;
        } else {
            return Jeu.PRISE_MAX;
        }
    }
}
