# ENIGMA

## **Script d'Installation pour la Cybersécurité**

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Ce script automatise l'installation et la configuration d'une suite complète d'outils essentiels pour la cybersécurité sur des systèmes Linux. Il est conçu pour simplifier la configuration d'un environnement sécurisé et efficace, adapté aux professionnels de la sécurité, chercheurs, étudiants ou passionnés.

---

## **Table des Matières**

1. [Description du Projet](#description-du-projet)
2. [Caractéristiques Principales](#caractéristiques-principales)
3. [Prérequis](#prérequis)
4. [Installation](#installation)
5. [Utilisation](#utilisation)
6. [Liste des Programmes Installés](#liste-des-programmes-installés)
7. [Personnalisation](#personnalisation)
8. [Contributions](#contributions)
9. [Licence](#licence)

---

## **Description du Script**

L'objectif principal de ce script est de fournir une solution rapide et facile pour configurer un environnement dédié à la cybersécurité. Il automatise l'installation de nombreux outils populaires, vérifie s'ils sont déjà installés et configure les permissions nécessaires pour leur utilisation.

Ce script est idéal pour :

- Les **professionnels de la cybersécurité** qui ont besoin d'un environnement prêt à l'emploi.
- Les **chercheurs en vulnérabilités** qui veulent tester des scénarios d'attaque ou de défense.
- Les **étudiants en sécurité informatique** qui apprennent à utiliser des outils spécialisés.
- Toute personne intéressée par l'apprentissage des techniques de cybersécurité.

---

## **Caractéristiques Principales**

- **Automatisation complète :** Installe tous les outils nécessaires sans intervention manuelle.
- **Vérification préalable :** Vérifie si les outils sont déjà installés avant de tenter de les réinstaller.
- **Compatibilité multi-distribution :** Compatible avec les distributions basées sur Debian/Ubuntu (via `apt`), Fedora/RHEL (via `dnf`), Arch Linux (via `pacman`) et autres.
- **Configuration avancée :**
  - Configure les permissions `NOPASSWD` pour éviter la saisie répétée de mots de passe lors de l'exécution de commandes administratives.
  - Gère les installations via `snap`, `flatpak` et `AppImage`.
- **Extensibilité :** Facilement personnalisable pour ajouter ou supprimer des outils selon vos besoins.

---

## **Prérequis**

Avant d'exécuter le script, assurez-vous que votre système répond aux exigences suivantes :

- Système d'exploitation Linux (**testé sur Ubuntu, Debian, Fedora, Arch Linux et leurs dérivés**).
- Accès à un compte utilisateur avec privilèges superutilisateur (`sudo`).
- Connexion Internet stable pour télécharger et installer les outils.
- Espace disque suffisant pour l'installation des programmes (min 100Go).

---

## **Installation**

Suivez ces étapes simples pour installer et exécuter le script :

1. Clonez ce dépôt sur votre machine locale :

   ```bash
   git clone https://github.com/votre-utilisateur/cybersecurity-setup.git
   cd cybersecurity-setup
   ```

2. Rendez le script exécutable :

   ```bash
   chmod +x setup.sh
   ```

3. Exécutez le script :
   ```bash
      ./setup.sh
   ```

---

## **Liste des Programmes Installés**

Le script installe et configure une liste complète d'outils populaires pour la cybersécurité. Voici une classification par catégorie :

---

### **Applications Cyber**

- **Docker :** Plateforme de conteneurisation pour créer des environnements isolés.
- **DVWA (Damn Vulnerable Web Application) :** Application web vulnérable conçue pour tester les vulnérabilités.
- **Exegol :** Environnement virtuel préconfiguré pour les tests de pénétration.
- **Add-ons pour Firefox :** Extensions de sécurité et de confidentialité pour le navigateur Firefox.

---

### **Logiciels Cyber**

- **Sublime Text / VSCode :** Éditeurs de texte puissants pour le développement et l'analyse de scripts.
- **Nmap :** Outil de scan réseau et de ports pour découvrir les hôtes et services.
- **Wireshark :** Analyseur de trafic réseau pour capturer et inspecter les paquets.
- **Hydra :** Outil de force brute pour tester les mécanismes d'authentification.
- **Burp Suite :** Suite complète pour l'analyse et l'exploitation des vulnérabilités web.
- **SpiderFoot :** Outil automatisé pour la collecte d'informations et la reconnaissance.
- **Nessus :** Scanner de vulnérabilités pour identifier les failles de sécurité.
- **SQLMap :** Outil d'exploitation de vulnérabilités SQL pour tester les bases de données web.
- **MySQL :** Système de gestion de base de données relationnelle pour tester les vulnérabilités SQL.
- **Metasploit Framework :** Framework puissant pour les tests de pénétration et l'exploitation de vulnérabilités.
- **DRADIS :** Outil de gestion de reporting pour les tests de pénétration.
- **SYSREPTOR :** Outil de gestion des incidents et des rapports de sécurité.
- **Setoolkit :** Social-Engineer Toolkit pour les attaques de phishing et d'ingénierie sociale.
- **Footprinting :** Ensemble de techniques pour recueillir des informations sur une cible.
- **theHarvester :** Outil de collecte d'informations pour identifier des e-mails, sous-domaines et autres détails.
- **Reconftw :** Framework automatisé pour la reconnaissance et l'énumération de cibles.
- **Spoofing :** Techniques pour simuler l'identité d'une cible dans le cadre d'attaques ou d'analyses.
- **GParted :** Éditeur de partitions pour gérer les disques et systèmes de fichiers.

---

> **Note :** Vous pouvez personnaliser la liste des programmes en modifiant le fichier `setup.sh`.

## **Personnalisation**

Si vous souhaitez ajouter ou supprimer des outils, modifiez directement la section correspondante dans le fichier `setup.sh`. Par exemple :

```bash
tools=("nmap" "wireshark" "metasploit-framework" "hydra")
```

Ajoutez ou supprimez les noms des outils selon vos besoins.

---

## **Contributions**

Les contributions sont les bienvenues ! Si vous souhaitez améliorer ce projet, suivez ces étapes :

1. Faites un fork du dépôt.
2. Créez une nouvelle branche (`git checkout -b feature/nouvelle-fonctionnalité`).
3. Effectuez vos modifications et faites un commit (`git commit -m "Ajoute un nouvel outil XYZ"`).
4. Publiez vos modifications (`git push origin feature/nouvelle-fonctionnalité`).
5. Ouvrez une Pull Request.

---

## **Licence**

Ce projet est sous licence **MIT**. Consultez le fichier [LICENSE](LICENSE) pour plus de détails.
