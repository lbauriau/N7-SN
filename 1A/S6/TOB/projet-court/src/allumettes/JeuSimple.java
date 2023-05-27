package allumettes;

public class JeuSimple implements Jeu {

	/**Choix du nombre initial d'allumette*/
	private final int allumettesInit = 13;

	/**Un seul attribut le nombre d'allumettes encore en jeu*/
	private int allumettesEnJeu;

	/** Constructeur de Jeu Simple.
	 */
	public JeuSimple(int nbAllumettes) {
		this.allumettesEnJeu = nbAllumettes;
	}

	public JeuSimple() {
		this.allumettesEnJeu = allumettesInit;
	}

	@Override
	public int getNombreAllumettes() {
		return this.allumettesEnJeu;
	}

	@Override
	public void retirer(int nbPrises) throws CoupInvalideException {
		int nbAllumettes = this.allumettesEnJeu;
		int possibleAllumettes = Math.min(nbAllumettes, PRISE_MAX);
		if (nbPrises > possibleAllumettes) {
			throw new CoupInvalideException(nbPrises,
					" (> " + possibleAllumettes + ")");
		} else if (nbPrises < 1) {
			throw new CoupInvalideException(nbPrises,
					" (< 1)");
		} else {
			this.allumettesEnJeu = this.allumettesEnJeu - nbPrises;
		}
	}

	@Override
	public void retirerTriche() throws CoupInvalideException {
		if (this.allumettesEnJeu == 2) {
			throw new CoupInvalideException(allumettesEnJeu,
					" allumette en jeu. On ne peut pas"
							+ "tricher quand il reste 2 allumettes");
		}
		this.allumettesEnJeu = 2;
	}

}
