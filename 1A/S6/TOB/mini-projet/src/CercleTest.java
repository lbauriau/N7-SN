import java.awt.Color;
import org.junit.*;
import static org.junit.Assert.*;

/**
 * Classe de test (en complément) de la classe Cercle.
 * @author	Laura Bauriaud
 * @version	1.1
 */
public class CercleTest {

    // précision pour les comparaisons réelles
    public final static double EPSILON = 0.0001;

    // Les points du sujet
    private Point A, B, C, D, E, F;

    // Les cercles du sujet
    private Cercle C1, C2, C3, C4;

    @Before public void setUp() {
        // Construire les points
        A = new Point(1, 2);
        B = new Point(2, 1);
        C = new Point(4, 1);
        D = new Point(8, 1);
        E = new Point(8, 4);
    }

    @Test public void testerE12() {
        C2 = new Cercle(A,B);
        F = new Point((A.getX()+B.getX())/2,(A.getY()+B.getY())/2);
        double r =  A.distance(B)/2;
        assertEquals("E12", C2.getCouleur(), Color.blue);
        assertEquals("E12", C2.getRayon(), r, EPSILON);
        assertEquals("E12", C2.getCentre().getX(), F.getX(), EPSILON);
        assertEquals("E12", C2.getCentre().getY(), F.getY(), EPSILON);
    }
    @Test public void testerE13() {
        C4 = new Cercle(C,D,Color.red);
        F = new Point((C.getX()+D.getX())/2,(C.getY()+D.getY())/2);
        double r = C.distance(D)/2;
        assertEquals("E13", C4.getCouleur(), Color.red);
        assertEquals("E13", C4.getRayon(), r, EPSILON);
        assertEquals("E13", C4.getCentre().getX(), F.getX(), EPSILON);
        assertEquals("E13", C4.getCentre().getY(), F.getY(), EPSILON);
    }
    @Test public void testerE14() {
        Cercle C5 = Cercle.creerCercle(D,E);
        double r = D.distance(E);
        F = new Point(D.getX(),D.getY());
        assertEquals("E14", C5.getRayon(), r, EPSILON);
        assertEquals("E14", C5.getCouleur(), Color.blue);
        assertEquals("E14", C5.getCentre().getX(), F.getX(), EPSILON);
        assertEquals("E13", C5.getCentre().getY(), F.getY(), EPSILON);
    }

}