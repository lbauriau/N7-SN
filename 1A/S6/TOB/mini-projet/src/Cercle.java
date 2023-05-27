import java.awt.Color;

/**
 * Nous allons définir la classe cercle.
 *
 * @author Laura Bauriaud
 * @version version 2.0
 */

public class Cercle implements Mesurable2D {
    /**
     * Centre du cercle.
     */
    private Point centre;
    /**
     * Rayon du cercle.
     */
    private double rayon;
    /**
     * Couleur du point.
     */
    private Color couleur;
    /**
     * Valeur de EPSILON.
     */
    public static final double EPSILON = 1e-6;
    /**
     * Déclaration de pi.
     */
    public static final double PI = Math.PI;

    /**
     * Construisons un cercle à partir de son rayon, de son centre et de sa couleur.
     *
     * @param ptCentre centre
     * @param rayon    rayon du cercle
     * @param couleur  couleur du cercle
     */
    private Cercle(Point ptCentre, double rayon, Color couleur) {
        assert (ptCentre != null);
        assert (rayon > 0);
        assert (couleur != null);
        this.centre = new Point(ptCentre.getX(), ptCentre.getY());
        this.rayon = rayon;
        this.couleur = couleur;
    }

    /**
     * Construisons un cercle à partir de son rayon et de son centre.
     * @param ptCentre centre
     * @param rayon    rayon du cercle
     */
    public Cercle(Point ptCentre, double rayon) {
        this(ptCentre, rayon, Color.blue);
    }

    /**
     * Construire un cercle à partir de deux points définissant le diamètre et la couleur.
     * @param p1      premier point
     * @param p2      second point,  diamétralement opposé au premier
     * @param couleur couleur du cercle
     */
    public Cercle(Point p1, Point p2, Color couleur) {
        assert (p1 != null);
        assert (p2 != null);
        boolean b1 = p1.getX() == p2.getX();
        boolean b2 = p1.getY() == p2.getY();
        assert (!b1 || !b2);
        this.rayon = p1.distance(p2) / 2;
        double x = (p1.getX() + p2.getX()) / 2;
        double y = (p1.getY() + p2.getY()) / 2;
        this.centre = new Point(x, y);
        this.couleur = couleur;
    }

    /**
     * Contruire un cercle à partir de deux points se situant sur le périmètre.
     * Et la couleur.
     * @param p1 premier point
     * @param p2 second point, diamétralement opposé au premier
     */
    public Cercle(Point p1, Point p2) {
        this(p1, p2, Color.blue);
    }

    /**
     * Créer un cercle à partir de deux points, le centre et un point sur le périmètre.
     *
     * @param centre    centre du cercle
     * @param ptCirconf point appartenant à la circonférence du cercle
     * @return le nouveau cercle
     */
    public static Cercle creerCercle(Point centre, Point ptCirconf) {
        assert (centre != null);
        assert (ptCirconf != null);
        boolean b1 = centre.getX() == ptCirconf.getX();
        boolean b2 = centre.getY() == ptCirconf.getY();
        assert (!b1 || !b2);
        double r = centre.distance(ptCirconf);
        return new Cercle(centre, r);
    }

    /**
     * Translater un cercle en précisant le déplacement suivant x et y.
     *
     * @param dx déplacement selon x
     * @param dy déplacement selon y
     */
    public void translater(double dx, double dy) {
        this.centre.translater(dx, dy);
    }

    /**
     * Obtenir le centre du cercle.
     *
     * @return le centre du cercle
     */
    public Point getCentre() {
        return new Point(this.centre.getX(), this.centre.getY());
    }

    /**
     * Obtenir le rayon du cercle.
     *
     * @return le rayon du cercle
     */
    public double getRayon() {
        return this.rayon;
    }

    /**
     * Obtenir le diamètre du cercle.
     *
     * @return le diamètre du cercle
     */
    public double getDiametre() {
        return 2 * this.rayon;
    }

    /**
     * Changer le rayon du cercle.
     *
     * @param r rayon du cercle
     */
    public void setRayon(double r) {
        boolean b = (r > 0);
        assert (b);
        this.rayon = r;
    }

    /**
     * Changer le rayon du cercle à partir du nouveau diamètre.
     *
     * @param d nouveau diamètre du cercle
     */
    public void setDiametre(double d) {
        boolean b = (d > 0);
        assert (b);
        this.rayon = d / 2;
    }

    /**
     * Savoir si le point est à l'intérieur du cercle.
     *
     * @param pt point à tester
     * @return un booléen pour savoir si le point appartient au cercle ou non
     */
    public boolean contient(Point pt) {
        assert (pt != null);
        Point ptCentre = this.centre;
        double d = ptCentre.distance(pt);
        return d <= this.rayon;
    }

    /**
     * Obtenir le périmètre du cercle.
     *
     * @return le périmètre du cercle
     */
    @Override
    public double perimetre() {
        double r = this.rayon;
        return 2 * r * PI;
    }

    /**
     * Obtenir l'aire du cercle.
     *
     * @return l'aire du cercle
     */

    @Override
    public double aire() {
        double r = this.rayon;
        return PI * r * r;
    }

    /**
     * Obtenir la couleur d'un cercle.
     *
     * @return la couleur du cercle
     */
    public Color getCouleur() {
        return this.couleur;
    }

    /**
     * Changer la couleur du cercle.
     *
     * @param couleur nouvelle couleur du cercle
     */
    public void setCouleur(Color couleur) {
        assert (couleur != null);
        this.couleur = couleur;
    }

    /**
     * Afficher un cercle dans le terminal avec la forme suivante Cr@(a,b).
     *
     * @return une chaine de caractère correspondant au cercle
     */
    public String toString() {
        return ("C" + this.rayon + "@" + this.centre.toString());
    }

    /**
     * Afficher le point.
     */
    public void afficherCercle() {
        System.out.print(this);
    }
}
