package allumettes;

public class JeuProcuration implements Jeu {

	private Jeu jeuProcuration;
	public JeuProcuration(Jeu jeu1) {
		this.jeuProcuration = jeu1;
	}
	@Override
	public int getNombreAllumettes() {
		return this.jeuProcuration.getNombreAllumettes();
	}
	@Override
	public void retirer(int nbPrises)
			throws CoupInvalideException, OperationInterditeException {
		throw new OperationInterditeException(" ");
	}
	@Override
	public void retirerTriche() throws CoupInvalideException,
			OperationInterditeException {
		throw new OperationInterditeException(" ");
	}

}
