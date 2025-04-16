# **Installation Suite Cyber (Enigma)**

![GitHub](https://img.shields.io/badge/Version-v1.1-blue) ![License](https://img.shields.io/badge/License-MIT-green)

Ce script automatise l'installation d'un ensemble complet d'outils de cybersécurité, développement et administration système sur des distributions Linux basées sur Debian, Red Hat, ou Arch. Il est conçu pour les professionnels de la sécurité, les développeurs et les administrateurs système.

## **Table des matières**

1. [Description](#description)
2. [Fonctionnalités principales](#fonctionnalités-principales)
3. [Prérequis](#prérequis)
4. [Installation](#installation)
5. [Programmes installés](#programmes-installés)
6. [Contribution](#contribution)
7. [Licence](#licence)

---

## **Description**

Ce script configure un environnement complet pour les tests de pénétration, les audits de sécurité et le développement. Il installe une variété d'outils via le gestionnaire de paquets du système, Docker, Python (`pip`), et Snap. Le script est modulaire et peut être exécuté sans privilèges root.

---

## **Fonctionnalités principales**

- **Automatisation complète** : Installation de tous les outils nécessaires sans intervention manuelle.
- **Support multi-distribution** : Compatible avec Ubuntu, Debian, Fedora, CentOS, Arch, etc.
- **Gestion des dépendances** : Vérifie et installe les dépendances requises avant de procéder.
- **Configuration de Docker** : Installe et configure Docker pour exécuter des conteneurs spécifiques.
- **Personnalisation** : Les programmes peuvent être ajoutés ou supprimés facilement dans le script.
- **Interface utilisateur intuitive** : Messages colorés et animations pour suivre l'avancement.

---

## **Prérequis**

Avant d'exécuter ce script, assurez-vous que votre système respecte les conditions suivantes :

1. **Système d'exploitation** :
   - Une distribution Linux basée sur Debian, Red Hat ou Arch.
2. **Accès Internet** :
   - Le script télécharge des paquets et des images Docker depuis Internet.
3. **Droits d'administration** :
   - Vous devez avoir accès à un compte utilisateur avec des privilèges `sudo`.
4. **Espace disque suffisant** :
   - Assurez-vous d'avoir au moins 10 Go d'espace libre pour installer tous les outils.

---

## **Installation**

1. **Télécharger le script** :

   ```bash
   curl -fsSL https://github.com/cristianmeyers/enigma/blob/main/cyber.sh -o install.sh
   ```

2. **Rendre le script exécutable** :

   ```bash
   chmod +x cyber.sh
   ```

3. **Exécuter le script** :

   ```bash
   ./cyber.sh
   ```

4. **Suivre les instructions** :
   - Le script vous guidera tout au long du processus. Il peut demander votre mot de passe `sudo` et certaines configurations supplémentaires.

---

## **Programmes installés**

### **Outils installés via le gestionnaire de paquets**

- **nmap** : Scanner de réseau et de ports.
- **wireshark** : Analyseur de trafic réseau.
- **hydra** : Outil de force brute pour tester les authentifications.
- **sqlmap** : Exploitation de vulnérabilités SQL.
- **mysql-server** : Serveur de base de données MySQL.
- **snapd** : Gestionnaire de paquets Snap.
- **geoip-bin** : Utilitaire de géolocalisation par IP.
- **sublist3r** : Enumération de sous-domaines.
- **nikto** : Scanner de vulnérabilités web.
- **dsniff** : Ensemble d'outils pour l'audit réseau.
- **hping3** : Outil de test réseau et d'attaques simulées.
- **macchanger** : Changement d'adresse MAC.
- **git** : Système de contrôle de versions.
- **openssl** : Outils cryptographiques.
- **uuid-runtime** : Générateur d'identifiants uniques universels (UUID).
- **gparted** : Éditeur de partitions de disque.
- **tar** : Compression et décompression de fichiers.
- **coreutils** : Utilitaires de base du système.

### **Outils installés via Docker**

- **spiderfoot** : Outil d'intelligence sur les sources ouvertes (OSINT).
- **DVWA (Damn Vulnerable Web Application)** : Application web vulnérable pour les tests de sécurité.
- **Sysreptor** : Outil pour les audits de conformité réglementaire.
- **Nessus** : Scanner avancé de vulnérabilités.

### **Outils installés via Python**

- **python3** : Environnement Python 3.
- **pipx** : Installation isolée d'applications Python.
- **SEToolKit (Social Engineer Toolkit)** : Ensemble d'outils pour l'ingénierie sociale.
- **Exegol** : Environnement personnalisé pour les tests de pénétration.

### **Outils installés via Snap**

- **Metasploit Framework** : Plateforme pour le développement et l'exécution d'exploits.

---

## **Contribution**

Les contributions sont les bienvenues ! Si vous souhaitez améliorer ce script, veuillez suivre ces étapes :

1. **Fork** ce dépôt.
2. Créez une branche pour vos modifications :
   ```bash
   git checkout -b feature/nom-de-votre-feature
   ```
3. Soumettez une pull request avec une description détaillée de vos modifications.

---

## **Licence**

Ce projet est sous licence MIT. Consultez le fichier [LICENSE](LICENSE) pour plus de détails.

---

## **Auteur**

- **Cristian** : Créateur principal du script.
- Contributions spéciales : Jérémy, Vincent.

Si vous avez des questions ou des suggestions, n'hésitez pas à ouvrir une issue ou à me contacter directement.

---

Merci d'utiliser ce script ! 🚀
