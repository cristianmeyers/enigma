# **Script d'Installation pour la Cybersécurité**

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Ce script automatise l'installation d'une série d'outils essentiels pour la cybersécurité sur les systèmes Linux. Il est conçu pour simplifier la configuration d'un environnement sécurisé et efficace pour les professionnels de la sécurité, les chercheurs ou les passionnés.

---

## **Table des Matières**

1. [Description du Projet](#description-du-projet)
2. [Caractéristiques Principales](#caractéristiques-principales)
3. [Prérequis](#prérequis)
4. [Installation](#installation)
5. [Utilisation](#utilisation)
6. [Liste des Programmes Installés](#liste-des-programmes-installés)
7. [Contributions](#contributions)
8. [Licence](#licence)

---

## **Description du Projet**

L'objectif de ce script est de fournir une solution rapide et facile pour configurer un environnement de cybersécurité sur les systèmes Linux. Il automatise l'installation d'outils clés, vérifie s'ils sont déjà installés et configure les permissions nécessaires pour leur utilisation.

Ce projet est idéal pour :

- Les professionnels de la cybersécurité.
- Les chercheurs en vulnérabilités.
- Les étudiants en sécurité informatique.
- Toute personne intéressée par l'apprentissage des outils de cybersécurité.

---

## **Caractéristiques Principales**

- **Automatisation :** Installe automatiquement tous les outils nécessaires sans intervention manuelle.
- **Vérification :** Vérifie si les outils sont déjà installés avant de tenter de les réinstaller.
- **Compatibilité :** Compatible avec les distributions basées sur Debian/Ubuntu et autres utilisant `apt`, `snap`, `flatpak` ou `AppImage`.
- **Configuration de Sudo :** Configure les permissions `NOPASSWD` pour éviter la saisie répétée de mots de passe lors de l'exécution de commandes administratives.
- **Personnalisable :** Facilement extensible pour ajouter plus d'outils selon vos besoins.

---

## **Prérequis**

- Système d'exploitation Linux (testé sur Ubuntu, Debian et dérivés).
- Accès à un compte avec privilèges superutilisateur (`sudo`).
- Connexion Internet pour télécharger et installer les outils.

---

## **Installation**

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

## **Utilisation**

Le script s'exécute automatiquement et effectue les actions suivantes :

1. Vérifie si les outils sont déjà installés.
2. Installe les outils manquants.
3. Configure les permissions `NOPASSWD` pour l'utilisateur actuel (optionnel).

Exemple d'exécution :

```bash
./setup.sh
```

Si vous souhaitez vérifier manuellement si un programme est installé, vous pouvez utiliser la fonction `is_installed` incluse dans le script :

```bash
is_installed "nmap"
```

---

## **Liste des Programmes Installés**

Le script installe et configure les outils populaires suivants pour la cybersécurité :

### **Outils de Scan et Analyse**

- **Nmap :** Outil de scan réseau et de ports.
- **Wireshark :** Analyseur de trafic réseau.
- **Nikto :** Scanner de vulnérabilités web.

### **Outils de Pénétration**

- **Metasploit Framework :** Framework pour les tests de pénétration.
- **Hydra :** Outil de force brute pour les attaques d'authentification.
- **John the Ripper :** Cracker de mots de passe.

### **Outils de Confidentialité et Sécurité**

- **Tor :** Navigateur pour une navigation anonyme.
- **GPG :** Outil de chiffrement et de signature numérique.
- **OpenVPN :** Client VPN pour des connexions sécurisées.

### **Outils de Surveillance**

- **Fail2Ban :** Protection contre les attaques de force brute.
- **ClamAV :** Antivirus open source.

> **Note :** Vous pouvez personnaliser la liste des programmes en modifiant le fichier `setup.sh`.

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
