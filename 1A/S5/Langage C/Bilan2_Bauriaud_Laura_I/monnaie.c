#include <stdlib.h> 
#include <stdio.h>
#include <assert.h>
#include <stdbool.h>

// Definition du type monnaie
struct t_monnaie {
	double valeur;
	char devise;
};

typedef struct t_monnaie t_monnaie;

/**
 * \brief Initialiser une monnaie 
 * \param[out] monnaie monnaie à initialiser
 * \param[in] val valeur de la monnaie
 * \param[in] dev devise de la devise
 * \pre val>0
 */

t_monnaie initialiser(double val, char dev){
	assert(val >0);
	t_monnaie monnaie;
	monnaie.valeur = val; 
	monnaie.devise = dev;
	return monnaie;
}


/**
 * \brief Ajouter une monnaie m2 à une monnaie m1 
 * \param[out] booléen pour savoir si l'opération a eu lieu ou non
 * \param[in] m1 monnaie 1
 * \param[in] m2 monnaie 2
 */ 
bool ajouter(t_monnaie *m1, t_monnaie *m2){
	bool b_devise = m1->devise == m2->devise;
	double* ptr_valeur = &m2->valeur;
	if (b_devise) {
	    *ptr_valeur = m2->valeur + m1->valeur;
	    }
	else{;}
	return b_devise;
}


/**
 * \brief Tester Initialiser 
 * \param[]
 * // initialise une monnaie
 */ 
void tester_initialiser(void){
    t_monnaie monnaie = initialiser (12,'e');
    t_monnaie monnaie1 = initialiser(1,'$');
    assert (monnaie.devise = 'e');
    assert (monnaie.valeur = 12);
    assert (monnaie1.devise='$');
}

/**
 * \brief Tester Ajouter 
 * \param[]
 * // On essaie avec deux monnaies avec deux devises identiques.
 * // On vérifie que la valeur de la seconde monnaie est bien modifées.
 * // On teste ensuite avec des devises différentes.
 */ 
void tester_ajouter(void){
	t_monnaie m1 = initialiser (12, '$');
	t_monnaie m2 = initialiser (8, 'e');
	t_monnaie m3 = initialiser (5, 'e');
	assert(true == ajouter(&m2,&m3));
	assert(false == ajouter(&m1,&m2));
	assert(m3.valeur == 13.0);
}

const int taille_porte_monnaie = 5;

int main(void){
	tester_initialiser();
	tester_ajouter();

    // Un tableau de 5 monnaies
    t_monnaie porte_monnaie[taille_porte_monnaie];

    //Initialiser les monnaies
    for (int i=0;i<taille_porte_monnaie;i++){
	    double val;
	    char dev;
	    printf("Entrer la valeur de la %d ième monnaie\n", i+1);
	    scanf("%lf",&val);
	    printf("Entrer la valeur de la %d ième devise\n", i+1);
	    scanf("%s",&dev);
	    porte_monnaie[i] = initialiser(val,dev);
    }
 
    // Afficher la somme de toutes les monnaies qui sont dans une devise entrée par l'utilisateur.
    t_monnaie somme_monnaie[taille_porte_monnaie];
    somme_monnaie[0].devise = porte_monnaie[0].devise;
    somme_monnaie[0].valeur = porte_monnaie[0].valeur;
    int k=0;

    //J'avais mal lu le sujet et je pensais qu'il fallait afficher la somme pour chaque devide.
    //J'ai donc juste modifié un peu mon code pour n'afficher que la bonne devise en gardant la strucure, si un jour je souhaite tout afficher
    for (int i=1;i<=taille_porte_monnaie;i++){
	    int j=0;
	    bool b = false;
	    while ( !b && j<=k){
		    b = ajouter(&porte_monnaie[i],&somme_monnaie[j]);
		    j++;
	    }  	    
	    if (j>k && !b) {
		    somme_monnaie[j].devise = porte_monnaie[i].devise;
		    somme_monnaie[j].valeur = porte_monnaie[i].valeur;
		    k++;
	    }
	    else {;}
    }

    //On affiche toutes les valeurs
    for (int i=0; i<k; i++){
	    printf("%d ième somme %lf %c\n", i+1,somme_monnaie[i].valeur, somme_monnaie[i].devise);
    }
    
    //On affiche seulement la valeur de la devise demandée
    char dev;
    printf("Entrer la devise dont vous souhaitez voir la somme\n");
    scanf("%s",&dev);
    bool b = false;
    bool * ptr_b = &b;

    for (int i=0; i<k; i++){
	    if (somme_monnaie[i].devise == dev){
		    printf("La valeur pour la devise %c est %lf\n", dev, somme_monnaie[i].valeur); 
		    * ptr_b = true;
	    } else {;};
    }
    if (!b) {
	    printf("Il n'y a pas de valeur pour la devise %c\n", dev);
    } else {;};
    
    return EXIT_SUCCESS;
}
