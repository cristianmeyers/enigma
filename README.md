# 🔐 Enigma — Installateur automatisé de suite cybersécurité

> Script Bash automatisé pour déployer un toolkit complet de cybersécurité sur Linux — inclut des outils offensifs, des conteneurs Docker, des environnements Python et des utilitaires d’accès à distance.

---

## 📋 Aperçu

**Enigma** est un script d’installation entièrement automatisé qui configure un environnement prêt à l’emploi pour le pentesting et la cybersécurité sur tout système Linux basé sur Debian/Ubuntu. Il gère l’installation des paquets, le déploiement de conteneurs Docker, les environnements virtuels Python et la configuration système — le tout en une seule commande.

Il supporte également un mode **désinstallation** pour supprimer tout ce qu’il a déployé.

---

## 🏗️ Architecture

```
enigma/
├── cyber.sh          # Script principal d’installation
└── README.md
```

---

## ⚙️ Contenu de l’installation

### 📦 Paquets système (via APT)

| Outil                | Description                              |
| -------------------- | ---------------------------------------- |
| `nmap`               | Scanner réseau et cartographie des ports |
| `wireshark`          | Analyseur de protocoles réseau           |
| `hydra`              | Brute-force de mots de passe en ligne    |
| `sqlmap`             | Outil automatisé d’injection SQL         |
| `nikto`              | Scanner de vulnérabilité de serveurs web |
| `hping3`             | Générateur de paquets TCP/IP             |
| `dsniff`             | Sniffing réseau et outils MITM           |
| `macchanger`         | Changement d’adresse MAC                 |
| `sublist3r`          | Énumération de sous-domaines             |
| `geoip-bin`          | Géolocalisation d’IP                     |
| `mysql-server`       | Serveur de base de données relationnelle |
| `openssl`            | Toolkit SSL/TLS                          |
| `git`, `curl`, `tar` | Utilitaires système essentiels           |

### 🐳 Conteneurs Docker

| Conteneur              | Description                                   | Port   |
| ---------------------- | --------------------------------------------- | ------ |
| `metasploit-framework` | Framework d’exploitation                      | `8080` |
| `nessus`               | Scanner de vulnérabilité                      | `8834` |
| `DVWA`                 | Damn Vulnerable Web Application (laboratoire) | —      |
| `spiderfoot`           | Outil d’automatisation OSINT                  | —      |
| `sysreptor`            | Plateforme de génération de rapports pentest  | —      |

### 🐍 Outils Python

| Outil       | Description                          | Méthode |
| ----------- | ------------------------------------ | ------- |
| `SEToolKit` | Framework d’ingénierie sociale       | pip     |
| `Exegol`    | Gestionnaire d’environnement pentest | pipx    |

### Snap

| Outil          | Description            |
| -------------- | ---------------------- |
| `Sublime Text` | Éditeur de code source |

---

## 🚀 Démarrage

### Prérequis

- Distribution Linux basée sur Debian / Ubuntu
- Compte utilisateur **non-root** avec accès `sudo`
- Connexion internet

### Utilisation

```bash
# Cloner le dépôt
git clone https://github.com/your-username/enigma.git
cd enigma

# Rendre le script exécutable
chmod +x enigma.sh

# Lancer l’installation
./enigma.sh
```

> ⚠️ **Ne pas exécuter en root.** Le script demandera votre mot de passe sudo et configurera sudo sans mot de passe automatiquement pendant l’installation.

### Désinstallation

```bash
./enigma.sh --uninstall
# ou
./enigma.sh -u
```

Le mode désinstallation supprime tous les paquets installés, conteneurs Docker, outils Python et nettoie les fichiers de configuration d’environnement.

---

## 🔧 Fonctionnement

Le script est structuré autour de fonctions modulaires indépendantes :

```
main()
├── passwd / no_passwd     → Configuration de l’authentification sudo
├── updater()              → Mise à jour système (apt / dnf / yum / pacman...)
├── package()              → Installation de paquets APT
├── packageBySnap()        → Installation via Snap
├── install_docker()       → Installation et configuration du moteur Docker
├── packageByDocker()      → Déploiement des conteneurs Docker
│   ├── Metasploit
│   ├── Spiderfoot
│   ├── DVWA
│   ├── Sysreptor
│   └── Nessus
└── packageByPython()      → Environnements Python venv + outils pip/pipx
    ├── SEToolKit
    └── Exegol
```

### Fonctions intelligentes

- **Support multi-distribution** — Détecte et utilise le gestionnaire de paquets disponible (`apt`, `dnf`, `yum`, `zypper`, `pacman`, `microdnf`)
- **Installation idempotente** — Chaque outil vérifie s’il est déjà installé avant de tenter l’installation (via `PATH`, `dpkg`, `snap`, `flatpak`, `AppImage` ou `Docker`)
- **Sous-shell Docker** — Les permissions du groupe Docker sont appliquées en cours de script via `newgrp` pour éviter de relancer une session complète
- **Indicateur animé** — Retour visuel pendant les opérations longues
- **Nettoyage automatique** — Suppression des fichiers temporaires et du mot de passe sudo en cache après l’installation

---

## 📋 Compatibilité

| Distribution     | Gestionnaire de paquets | Supporté |
| ---------------- | ----------------------- | -------- |
| Ubuntu / Debian  | `apt-get`               | ✅       |
| Fedora           | `dnf`                   | ✅       |
| RHEL / CentOS    | `yum`                   | ✅       |
| openSUSE         | `zypper`                | ✅       |
| Arch Linux       | `pacman`                | ✅       |
| Alpine (minimal) | `microdnf`              | ✅       |

---

## ⚠️ Avis légal

Cette suite est destinée à **des tests de sécurité autorisés, à l’enseignement et à des environnements de laboratoire contrôlés**.
L’utilisation de ces outils sur des systèmes sans autorisation explicite est illégale. Les auteurs ne sont pas responsables de toute mauvaise utilisation.

---

## 📄 Licence

MIT
