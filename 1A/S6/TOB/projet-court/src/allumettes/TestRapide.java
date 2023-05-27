package allumettes;
import org.junit.*;
import static org.junit.Assert.*;

/**
 * Classe de test pour Strategie Rapide.
 * @author	Laura Bauriaud
 * @version	1.1
 */
public class TestRapide {

	// Les jeux du sujet
	private Jeu jeu1, jeu2;
	// Les joueurs du sujet
	private Joueur joueur1, joueur2, joueur3;
	// La strategie rapide
	private Strategie strategieRapide;
	


	@ Before public void setUp() {
		// Construire les points
		this.joueur1 = new Joueur ("Xavier", strategieRapide);
		this.joueur2 = new Joueur ("Charles", strategieRapide);
		this.joueur3 = new Joueur ("Éloise", strategieRapide);
		this.jeu1 = new JeuSimple();
		this.jeu2 = new JeuSimple();
		this.strategieRapide = new StrategieRapide();
	}

	@ Test public void testerRapide1() {
		assertEquals("E1", this.strategieRapide.getPrise(jeu1, joueur1), Jeu.PRISE_MAX);
	}

}
