package allumettes;

public interface Strategie {

    /** En fonction de la stratégie, on voit combien d'allumettes ont été selectionnées
     * @return le nombre d'allumette que le joueur prend
     */
    int getPrise(Jeu jeu, Joueur joueur);
}
