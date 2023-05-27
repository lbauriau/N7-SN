/**
 *  \author Xavier Cr�gut <nom@n7.fr>
 *  \file file.c
 *
 *  Objectif :
 *	Implantation des op�rations de la file
*/

#include <malloc.h>
#include <assert.h>
#include <stdio.h>

#include "file.h"


void initialiser(File *f) {

    (f->tete) = NULL;
    (f->queue) = NULL;
    assert(est_vide(*f));
    
}


void detruire(File *f)
{
    Cellule * aux; 
    while (f->tete != NULL){
        aux = f->tete->suivante;
        free(f->tete);
        f->tete = aux;
    }
    f->queue = NULL;
}


char tete(File f)
{
    assert(! est_vide(f));
    return f.tete->valeur;
}


bool est_vide(File f)
{
    assert(&f != NULL);
    return (f.tete==NULL && f.queue==NULL);
}

/**
 * Obtenir une nouvelle cellule alloue dynamiquement
 * initialis�e avec la valeur et la cellule suivante pr�cis� en param�tre.
 */
static Cellule * cellule(char valeur, Cellule *suivante)
{
    Cellule * nouvelleCellule = malloc(sizeof(Cellule));
    nouvelleCellule->valeur = valeur;
    nouvelleCellule->suivante = suivante;
    return nouvelleCellule;
}


void inserer(File *f, char v)
{
    assert(f != NULL);
    Cellule * nouvelleCellule = cellule(v, NULL);
    if (est_vide(*f)){
        f->tete = nouvelleCellule;
    } else {
        f->queue->suivante = nouvelleCellule;
    }
    f->queue = nouvelleCellule;
}

void extraire(File *f, char *v)
{
    assert(f != NULL);
    assert(! est_vide(*f));
    *v = f->tete-> valeur;
    Cellule * chang = f->tete->suivante;
    free(f->tete);
    f->tete = chang;
    if (f->tete == NULL){
        f->queue = NULL;
    }
}


int longueur(File f)
{
    int n = 0;
    Cellule * aux = f.tete;
    while (aux != NULL){
        aux = aux->suivante;
        n = n+1;
    }
    return n;
}
