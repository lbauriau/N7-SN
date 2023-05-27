package allumettes;
import java.util.NoSuchElementException;
import java.util.Scanner;

public class StrategieHumain implements Strategie {
	private static Scanner scanner = new Scanner(System.in);
	/** Nous définissons la stratégie humain telle que :
	 * le joueur "humain" doit rentrer ses choix de prise
	 * d'allumettes au clavier.
	 */
    @Override
    public int getPrise(Jeu jeu, Joueur joueurHumain) {
    	int prise = 0;
    	String sortie;
    	boolean triche = false;
    	System.out.print(joueurHumain.getNom() + ", combien d'allumettes ? ");
    	while (true) {
			try {
				sortie = scanner.nextLine();
				if (sortie.equals("triche")) {
					try {
						triche = true;
						jeu.retirer(1);
						System.out.println("[Une allumette en moins, plus que "
							+ jeu.getNombreAllumettes() + ". Chut !]");
					} catch (CoupInvalideException e) { }
				}
			prise = Integer.parseInt(sortie);
			break;
			} catch (NumberFormatException e) {
				if (!triche) {
					System.out.println("Vous devez donner un entier.");
				}
			} catch (NoSuchElementException e) {
    		System.out.println("Veuillez remplir votre choix");
			}
			System.out.print(joueurHumain.getNom() + ", combien d'allumettes ? ");
		}
    	return prise;
    }
}
