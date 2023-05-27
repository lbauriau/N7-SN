package allumettes;

public class Joueur {

    /**
     * Nous avons besoin de connaître le nom du joueur et sa stratégie.
     */

    private String nom;
    private Strategie strat;

    /**
     * Constructeur de la classe Joueur.
     *
     * @param nom   intitulé du joueur
     * @param strat stratégie du joueur
     */
    public Joueur(String nom, Strategie strat) {
        this.nom = nom;
        this.strat = strat;
    }
    /** Obtenir le nom du joueur.
     * @return le nom du joueur
     */
    public String getNom() {
        return this.nom;
    }

    /** Obtenir la stratégie d'un joueur.
     * @return la stratégie
     */
    public Strategie getStrategie() {
        return this.strat;
    }

    public int getPrise(Jeu jeu) {
        return strat.getPrise(jeu, this);
    }
}
