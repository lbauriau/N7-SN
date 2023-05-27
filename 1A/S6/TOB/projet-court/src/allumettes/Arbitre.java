package allumettes;

/** Classe arbitre
 * @author	Laura Bauriaud
 * @version	1.0
 */

public class Arbitre {

    /** L'arbitre connait les deux joueurs, le joueur en jeu.
     * actuellement et s'il fait confiance ou non aux joueurs.
     */
    private final Joueur joueur1;
    private final Joueur joueur2;
    private Joueur enJeu;
    private Boolean confiance;

    /** Construisons un arbitre en donnant les deux joueurs.
     * ainsi que la politique de confiance.
     * @param joueur1 premier joueur
     * @param joueur2 second joueur
     * @param confiant paramètre de confiance
     */
    public Arbitre(Joueur joueur1, Joueur joueur2, Boolean confiant) {
        this.joueur1 = joueur1;
        this.joueur2 = joueur2;
        this.enJeu = joueur1;
        this.confiance = confiant;
    };

    /** Constructeur d'arbitre, par défaut il ne fait pas confiance aux joueurs.
     * @param joueur1 premier joueur
     * @param joueur2 second joueur
     */
    public Arbitre(Joueur joueur1, Joueur joueur2) {
        this(joueur1, joueur2, false);
    }

    /** Changer le paramètre de confiance.
     * @param confiance paramètre de confiance, booléen
     */
    public void setConfiance(Boolean confiance) {
        this.confiance = confiance;
    }

    /** Obtenir la politique de confiance.
     * @return un booléen qui représente la politique de confiance
     */
    public Boolean getConfiance() {
        return confiance;
    }

    /** Savoir quel joueur joue actuellement.
     * @return le joueur en jeux
     */
    public Joueur getEnJeu() {
        return enJeu;
    }

    /** Mettre à jour le jeu, on passe au joueur suivant.
     */
    public void nextJoueur() {
        if (this.joueur1 == this.enJeu) {
            this.enJeu = this.joueur2;
        } else {
            this.enJeu = this.joueur1;
        }
    }

    /** Fonction d'arbitrage de la partie.
     * @param jeu1 le jeu que l'on arbitre
     * @throws CoupInvalideException
     */
    public void arbitrer(Jeu jeu1) throws CoupInvalideException {
    	int nbAllumette = jeu1.getNombreAllumettes();
    	int allumettePrise;
        JeuProcuration jeuProc;
            while (nbAllumette > 0) {
                jeuProc = new JeuProcuration(jeu1);
                try {
                System.out.println("Allumettes restantes : " + nbAllumette);
                if (!this.confiance) {
                    try {
                        allumettePrise = this.enJeu.getPrise(jeuProc);
                    } catch (OperationInterditeException e) {
                        System.out.println("Abandon de la partie car "
                                + enJeu.getNom() + " triche ! ");
                        break;
                    }
                } else {
                    allumettePrise = this.enJeu.getPrise(jeu1);
                }
                jeu1.retirer(allumettePrise);
                nbAllumette = jeu1.getNombreAllumettes();
                if (allumettePrise == 1) {
                    System.out.println(enJeu.getNom() + " prend "
                            + allumettePrise + " allumette.");
                } else {
                    System.out.println(enJeu.getNom() + " prend "
                            + allumettePrise + " allumettes.");
                }
                System.out.println();
                this.nextJoueur();
            } catch (CoupInvalideException e) {
                    if (e.getCoup() > 1) {
            		    System.out.println(enJeu.getNom() + " prend "
                                + e.getCoup() + " allumettes.");
                    } else {
                        System.out.println(enJeu.getNom() + " prend "
                                + e.getCoup() + " allumette.");
                    }
                    System.out.println("Impossible ! Nombre invalide : "
                            + e.getCoup() + e.getProbleme());
                    System.out.println();
                } catch (OperationInterditeException e) {
                    System.out.println("Abandon de la partie car "
                            + enJeu.getNom() + " triche ! ");
                    break;
                }
            }
            if (nbAllumette == 0) {
                if (this.enJeu.equals(joueur1)) {
                    System.out.println(joueur2.getNom() + " perd !");
                    System.out.println(joueur1.getNom() + " gagne !");
                } else {
                    System.out.println(joueur1.getNom() + " perd !");
                    System.out.println(joueur2.getNom() + " gagne !");
                }
            }
    }
}
