package allumettes;

/** Lance une partie des 13 allumettes en fonction des arguments fournis
 * sur la ligne de commande.
 * @author	Xavier Crégut
 * @version	$Revision: 1.5 $
 */
public class Jouer {

	public Jouer() { };
	/** Lancer une partie. En argument sont donnés les deux joueurs sous
	 * la forme nom@stratégie.
	 * @param args la description des deux joueurs
	 * @throws CoupInvalideException
	 */
	public static void main(String[] args) throws CoupInvalideException {
		Joueur joueur1;
		Joueur joueur2;
		Jeu jeu1 = new JeuSimple();
		int indiceConf = 0;
		try {
			verifierNombreArguments(args);
			if (args[0].contentEquals("-confiant")) { //args[0]
				indiceConf = 1;
			}
			joueur1 = defJoueur(args[0 + indiceConf]);
			joueur2 = defJoueur(args[1 + indiceConf]);
			Arbitre arbitre = new Arbitre(joueur1, joueur2, (indiceConf == 1));
			arbitre.arbitrer(jeu1);
		} catch (ConfigurationException e) {
			System.out.println();
			System.out.println("Erreur : " + e.getMessage());
			afficherUsage();
			System.exit(1);
		}
	}

	private static void verifierNombreArguments(String[] args) {
		final int nbJoueurs = 2;
		if (args.length < nbJoueurs) {
			throw new ConfigurationException("Trop peu d'arguments : "
					+ args.length);
		}
		if (args.length > nbJoueurs + 1) {
			throw new ConfigurationException("Trop d'arguments : "
					+ args.length);
		}
	}

	/** Afficher des indications sur la manière d'exécuter cette classe. */
	public static void afficherUsage() {
		System.out.println("\n" + "Usage :"
				+ "\n\t" + "java allumettes.Jouer joueur1 joueur2"
				+ "\n\t\t" + "joueur est de la forme nom@stratégie"
				+ "\n\t\t" + "strategie = naif | rapide | expert | humain | tricheur"
				+ "\n"
				+ "\n\t" + "Exemple :"
				+ "\n\t" + "	java allumettes.Jouer Xavier@humain "
					   + "Ordinateur@naif"
				+ "\n"
				);
	}
	/**Constructeur de joueur directement à partir de la lige de commande
     * @param commande
     */
    public static Joueur defJoueur(String commande) {
    	String valeurStrat;
    	String nom;
    	Strategie strategie;
    	try {
    		String[] tabCommande = commande.split("@", 2);
    		nom = tabCommande[0];
    		valeurStrat = tabCommande[1];
    	} catch (ArrayIndexOutOfBoundsException x) {
    		throw new ConfigurationException("La ligne de commande n'est pas valide.");
    	}
		switch (valeurStrat) {
		case "humain":
			strategie = new StrategieHumain();
			break;
		case "naif" :
			strategie = new StrategieNaif();
			break;
		case "rapide" :
			strategie = new StrategieRapide();
			break;
		case "expert" :
			strategie = new StrategieExpert();
			break;
		case "tricheur":
			strategie = new StrategieTricheur();
			break;
		default :
			throw new ConfigurationException("La ligne de commande n'est pas valide.");
    	}
		return new Joueur(nom, strategie);
    }
}
