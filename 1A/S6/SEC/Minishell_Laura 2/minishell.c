/*Utilisation de kill*/
#define _XOPEN_SOURCE 700

#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h> /* wait */
#include <sys/types.h>
#include <fcntl.h>
#include <signal.h>
#include "readcmd.h"


/*Définition des constantes*/
#define PROCESSUS_MAX 500

/*Définition des attributs dans les focntions*/
int wstatus;
int ret;
int id_pid, codeTerm, res, reussite, des;
/*Nombre de processus*/
int nb_processus;

/*Savoir si un processus est en avant plan*/
int avantPlan;

struct cmdline *line;
int go;

struct gestion {
    /*États des processus : premier plan ou arrière plan*/
    // 0 premier plan
    // 1 arrière plan
    int etat;

    /*Pid des processus*/
    int pid;

    /*Commande*/
    char cmd[50];

    /*identifiant dans le minishell*/
    int id;
};

typedef struct gestion gestion;

gestion globale[PROCESSUS_MAX];

struct sigaction sigAction;

/*Redirections*/

/*Redirection de l'entrée*/
void redirection_entree (struct cmdline *line) {
    if (line-> in != NULL){
        des = open(line -> in, O_RDONLY, 0777);
        if (des<0){
            perror("Erreur dans la redirection de l'entrée :");
            exit(5);
        }
        ret = dup2(des, 0);
        if (ret <0){
            perror("Erreur dans le dup");
        }
    }
}

/*Redirection de la sortie*/
void redirection_sortie (struct cmdline *line){
    if (line-> out != NULL){
        des = open(line -> out, O_WRONLY | O_CREAT | O_TRUNC, 0777);
        if (des<0){
            perror("Erreur dans la redirection de la sortie :");
            exit(6);
        }
        ret = dup2(des, 1);
        if (ret <0){
            perror("Erreur dans le dup");
        }
    }
}

/*Redirection générale*/
void redirection_globale(struct cmdline *line){
    redirection_entree(line);
    redirection_sortie(line);

}


/*Définition des commandes*/

/*Commande list jobs*/
void handler_jobs(){
    char *etat_i;
    printf( "[id]    pid       état        commande  \n");
    for(int ii = 0; ii<nb_processus; ii++){
        if (globale[ii].pid > 0){
            if (globale[ii].etat == 0) {
                // Le processus est au premier plan
                etat_i = "premier plan";
            } else {
                etat_i = "arrière plan";
            }
            
            printf(" %i    %i  %s    %s\n", ii+1, globale[ii].pid, etat_i, globale[ii].cmd);
        }
    }
}

/*Commande stop job*/
void handler_sj(struct cmdline *line, int proc){
    if (line->seq[proc][1]==NULL){
        printf("Vous devez fournir l'identifiant du processus\n");
    } else {
        int indi = (int) strtol(line->seq[proc][1], NULL, 10);
        pid_t pid_fils = globale[indi - 1].pid;
        if (pid_fils == 0){
            printf("Erreur on ne peut pas tuer le père");
        } else {
            int dead = kill(pid_fils, SIGKILL);
            /*Cas d'erreur*/
            if (dead<0){
                perror("Problème pour tuer un processus");
            } else {
                printf("Le processus %i est suspendu.\n", atoi(line->seq[proc][1]));
            }
        }
    }
}

/*Commande background*/
void handler_bg(struct cmdline *line, int proc){
    if (line->seq[proc][1]==NULL){
        printf("Vous devez fournir l'identifiant du processus\n");
    } else {
        // Premier cas : le processus est déjà en arrière plan
        int indi = (int) strtol(line->seq[proc][1], NULL, 10);
        if (globale[indi].etat == 1){
            printf("Le processus %i est déjà en arrière-plan\n", indi);
        } else {
            id_pid = globale[indi].pid;
            globale[indi].etat = 1;
            kill(id_pid, SIGCONT);
            printf("Le processus %i est mis en arrière-plan\n", id_pid);
        }
    }
}

/*Commande foreground*/
void handler_fg(struct cmdline *line, int proc){
    if (line->seq[proc][1]==NULL){
        printf("Vous devez fournir l'identifiant du processus\n");
    } else {
        int indi = (int) strtol(line->seq[proc][1], NULL, 10) - 1;
        id_pid = globale[indi].pid;
        if (id_pid ==0){
            printf("Vous n'avez pas renseigné le bon identifiant du processus");
        } else {
            globale[indi].etat = 0;
            printf("Le processus %i est mis au premier plan\n", id_pid);
            kill(id_pid, SIGCONT);
            avantPlan = id_pid;
        }
    }
}

/*Commande du cd*/
void handler_cd(struct cmdline*line, int proc){
    int indice =0;
    while (globale[indice].id != 0){
        indice ++;
    }
    globale[indice].id = nb_processus;
    if (line->seq[proc][1] != NULL){
        reussite = chdir(line->seq[proc][1]);
    } else {
        reussite = chdir("/");
    }
    if (reussite<0){
        printf("Erreur dans le cd\n");
        exit(2);
    }
}

/*Commande à la reception du SIGINT*/
void handler_int(int id_signal){

    //Vérification : traitement du bon signal
    if (id_signal == SIGINT){
        for (int i=0; i<nb_processus; i++){
            if(globale[i].etat==0 && globale[i].pid>0){
                printf(" Le processus %i est arrêté par int\n", globale[i].pid);
                kill(globale[i].pid, SIGKILL);
            }
        }
    } else {
        printf("Erreur : nous ne traitons pas le bon signal.");
    }
}

void handler_tstp(int id_signal){

    //Vérification : traitement du bon signal
    if (id_signal == SIGTSTP){
        for (int i=0; i<nb_processus; i++){
            if(globale[i].etat==0 && globale[i].pid>0){
                printf(" Le processus %i est arrêté par tstp.\n", globale[i].pid);
                kill(globale[i].pid, SIGSTOP);
                globale[i].etat=1;
            }
        }
    } else {
        printf("Erreur : nous ne traitons pas le bon signal.");
    }
}

/*Traitant pour les fils*/
void handler_child(int signal){

    pid_t pid;
    int wstatus;
    int j;

    if (signal == SIGCHLD){
        while ((pid = waitpid(-1, &wstatus, WNOHANG|WUNTRACED|WCONTINUED))>0) {
            j=0;
            while (globale[j].pid != pid && j < PROCESSUS_MAX){
                j++;
            }
            /*Changement d'état, gestion des différents cas*/

            // Processus terminé de lui même et par un signal reçu
            if (WIFEXITED(wstatus) || WIFSIGNALED(wstatus)){
                globale[j].pid = 0;
                globale[j].id = 0;
                globale[j].etat = 1;
                if (pid == avantPlan){
                    avantPlan = 0;
                }
            }

            //Relance le processus 
            else if (WIFCONTINUED(wstatus)){
                globale[j].etat = 0;
            }

            //Suspendre le processus
            else if (WIFSTOPPED(wstatus)){
                globale[j].etat = 1;
                if (pid == avantPlan){
                    avantPlan = 0;
                }
            }

            //Erreur
            else {
                printf("ERREUR : le fils a obligatoirement reçu un signal donc nous ne pouvons pas arriver ici !");
            }
        }
    }
}


 /*Commande générale*/
void handler_gen(struct cmdline *line, int proc){

    //On enregistre le nouveau processus dès que l'on trouve une place libre
    int indice = 0;
    while (globale[indice].id != 0){
        indice ++;
    }

    int index = 0;
    while (line->seq[index] != NULL){
        index++;
    }

    int tube[index-1][2];
    if (index>1){
        for (int j=0; j<index-1; j++) {
            pipe(tube[j]);
        }
    }

    for (int j=0; j<index; j++){
        //Création du fils
        id_pid = fork();
        if (id_pid<0) {
            printf("Erreur dans le fork");
            exit(3);
        }
        if (id_pid == 0) { /*Gestion du fils*/
                sleep(0.1);
                if (index>1){
                    if (j==0){
                        close(tube[j][0]);
                        for (int i = 1; i<index; i++){
                            close(tube[i][1]);
                            close(tube[i][0]);
                            }
                        dup2(tube[j][1],0);
                        redirection_entree(line);
                    } else if (j==index-1){
                        close(tube[j][1]);
                        for (int i = 0; i<index-1; i++){
                            close(tube[i][1]);
                            close(tube[i][0]);
                            }
                        dup2(tube[j][0],1);
                        redirection_sortie(line);
                    } else {
                        for (int i = 0; i<index; i++){
                            if (i!=j-1){
                                close(tube[i][0]);
                            }
                            if (i!=j){
                                close(tube[i][1]);
                            }
                        }
                        dup2(tube[j-1][0],1);
                        dup2(tube[j][1],0);
                    }
                } else {
                    redirection_globale(line);
                }

                //Masquage des signaux                
                sigset_t ens_sig;
                sigemptyset(&ens_sig);
                sigaddset(&ens_sig, SIGINT);
                sigaddset(&ens_sig, SIGTSTP);
                if (line-> backgrounded != NULL){
                    sigprocmask(SIG_BLOCK, &ens_sig, NULL);
                }
                
                execvp((char *)line->seq[proc][0], line->seq[proc]);
                perror("La commande demandée n'existe pas.\n");
                exit(4);

            } else { // Gestion du père
                
                // On met à jour avantPlan
                if (line->backgrounded == NULL) {
                    avantPlan = id_pid;
                    globale[indice].etat = 0;
                } else {
                    globale[indice].etat = 1;
                }
                
                if (j==0){
                    for (int jj = 0; jj< index-1; jj++){
                        close(tube[jj][1]);
                        close(tube[jj][0]);
                    } 
                }

                globale[indice].pid = id_pid;
                globale[indice].id = nb_processus;
                strcpy(globale[indice].cmd, line->seq[proc][0]);
            }
    }
}



/*Traitement des commandes*/
void handle_cmd(struct cmdline *line, int proc){

    if (strcmp(line->seq[proc][0], "cd")==0){ // Commande cd
        //Traitement dans le père
        handler_cd(line, proc);
    } else if (strcmp(line->seq[proc][0], "exit")==0){ // Commande exit
        //Traitement dans le père
        exit(EXIT_SUCCESS);
    } else if (strcmp(line->seq[proc][0], "lj")==0){ // Commande lj
        //Traitement dans un fils
        handler_jobs();
    } else if (strcmp(line->seq[proc][0], "sj")==0){ // Commande sj
        //Traitement dans un fils
        handler_sj(line, proc);
    } else if (strcmp(line->seq[proc][0], "bg")==0){ // Commande bg
        //Traitement dans un fils
        handler_bg(line, proc);
    } else if (strcmp(line->seq[proc][0], "fg")==0){ // Commande fg
        //Traitement dans un fils
        handler_fg(line, proc);
    } else { // Traitement général
        //Traitement dans un fils
        handler_gen(line, proc);
    }
}


/* Récupération des signaux*/
void recup_sigaction(){

    struct sigaction sig;

    sig.sa_handler = handler_child;
    sigemptyset(&sig.sa_mask);

    sig.sa_flags = SA_RESTART;
    sigaction(SIGCHLD, &sig, NULL);

    sig.sa_handler = handler_tstp;
    sigaction(SIGTSTP, &sig, NULL);

    sig.sa_handler = handler_int;
    sigaction(SIGINT, &sig, NULL);

}


/*Programme principal*/
int main(){

    avantPlan = 0;
    nb_processus = 0;
    go = 1;

    /*Tableau pour pouvoir gérer plusieurs processus en même temps*/
    for (int j = 0; j < PROCESSUS_MAX; j++) {
        globale[j].etat = 1;
        globale[j].pid = 0;
        globale[j].id = 0;
    }

    /* Initialisation des signaux*/
    recup_sigaction();

    /*Gestion des commandes*/
    while(go){

        while (avantPlan > 0){
            sleep(0.1);
        }

        printf(">>> ");
        line = readcmd();

        /*Gestion du processus*/
        if (line != NULL && line->seq[0] != NULL){
            /*Traitement*/
            handle_cmd(line, 0);
            nb_processus ++;
        }

        go = (line != NULL);

    }
}