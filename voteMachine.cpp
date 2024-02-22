#include <iostream>
#include <fstream>

using namespace std;

void adminMode(string);
void writeResults(string resultsPath, string candidatesName[9], int candidatesVotes[9]);

int main(){
    system("clear");
    string candidates;
    string results;
    cout << "## CONFIGURATION ##\nEntrez fichier candidats :" << endl;
    cin >> candidates;
    system("clear");
    cout << "## CONFIGURATION ##\nEntrez fichier résultats :" << endl;
    cin >> results;

    ifstream candidatesFile(candidates);
    ofstream resultsFile(results);
    string line;
    string candidatesName[9];
    int candidatesVotes[9];
    int lineNumber = 0;
    while (getline(candidatesFile, line)){
        if (line == "") continue;
        if (lineNumber == 9) break;  
        candidatesName[lineNumber] = line;
        candidatesVotes[lineNumber] = 0;
        resultsFile << line << " - 0;" << endl;
        lineNumber++;
    }
    string useless;
    system("clear");
    cout << "Lancement du vote... Entrez une touche pour continuer:" << endl;
    cin >> useless;
    system("clear");
    int choice;
    while(true){
        system("clear");
        cout << "Liste des candidats :\n0 - Vote blanc" << endl;
        for (int i = 0; i < 9; i++){
            if (candidatesName[i] != "") cout << i+1 << " - " << candidatesName[i] << endl;
        }
        cin >> choice;
        if (choice == 0) continue;
        if (choice == 10) {adminMode(results); continue;}
        if (choice > 0 && choice < 10) {candidatesVotes[choice-1]++; writeResults(results, candidatesName, candidatesVotes);}
    }
    return 0;
}

void adminMode(string resultsPath){
    int choice;
    string useless;
    while (true){
        system("clear");
        cout << "## Admin Mode ##:\n1 - Afficher les résultats\n2 - Continuer le vote\n3 - Finir le vote\n4 - Mettre à 0\nChoisisez une option :" << endl;
        cin >> choice;
        if (choice == 4){
            for (int i = 0; i < 9; i++){
               candidatesVotes[i] = 0;
            }
        }
        if (choice == 1 || choice == 3){
            system("clear");
            ifstream resultsFile(resultsPath);
            string line;
            cout << "Résultats ";
            if (choice == 1) cout << "temporaires :" << endl;
            if (choice == 3) cout << "finaux :" << endl;
            while (getline(resultsFile, line)){
                cout << line << endl;
            }
            if (choice == 1) {cout << "Entrez une touche pour continuer :" << endl;
            cin >> useless;}
        }
        if (choice == 2 || choice == 3) break;
    }
    if (choice == 3) exit(0);
}

void writeResults(string resultsPath, string candidatesName[9], int candidatesVotes[9]){
    ofstream resultsFile(resultsPath);
    for (int i = 0; i < 9; i++){
        if (candidatesName[i] == "") continue;
        resultsFile << candidatesName[i] << " - " << candidatesVotes[i] << ";" << endl;
    }
}