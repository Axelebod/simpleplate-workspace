# 📘 Guide d'utilisation - SimplePlate GitHub

## 🎯 Objectif
Tous les agents partagent les données via GitHub. C'est la source unique de vérité.

---

## 🔗 Accès

**Repo GitHub :** https://github.com/Axelebod/simpleplate-workspace

**Fichiers importants :**
- `data/leads.csv` → Liste des prospects
- `data/messages.csv` → Messages envoyés
- `data/sites.csv` → Sites créés

---

## 🚀 Workflow quotidien

### 1. Récupérer les dernières données
```bash
cd /root/.openclaw/workspace
git pull origin master
```

### 2. Faire tes modifications
**Exemple pour Scrapy (ajouter des leads) :**
```bash
# Éditer le fichier
cd /root/.openclaw/workspace/data
nano leads.csv

# Ajouter les nouveaux leads à la fin
```

### 3. Sauvegarder et partager
```bash
cd /root/.openclaw/workspace

# Voir ce qui a changé
git status

# Ajouter les modifications
git add data/leads.csv

# Créer un commit avec message
git commit -m "Scrapy: Ajout de 10 leads à Toulon"

# Envoyer sur GitHub
git push origin master
```

---

## 📝 Commandes essentielles

| Action | Commande |
|--------|----------|
| Voir l'état | `git status` |
| Récupérer les données | `git pull origin master` |
| Ajouter un fichier | `git add data/nomdufichier.csv` |
| Créer un commit | `git commit -m "Message clair"` |
| Envoyer sur GitHub | `git push origin master` |

---

## 🐶 Par agent

### Scrapy 🐶
**Ce que tu modifies :** `data/leads.csv`

**Workflow :**
```bash
git pull origin master
# Ajouter les nouveaux leads dans leads.csv
git add data/leads.csv
git commit -m "Scrapy: [nombre] leads ajoutés à [ville]"
git push origin master
```

### Hunter 🎯
**Ce que tu modifies :** `data/messages.csv`

**Workflow :**
```bash
git pull origin master
# Ajouter les messages envoyés
git add data/messages.csv
git commit -m "Hunter: [nombre] messages envoyés"
git push origin master
```

### Wilson 🏗️
**Ce que tu modifies :** `data/sites.csv`

**Workflow :**
```bash
git pull origin master
# Ajouter les sites créés
git add data/sites.csv
git commit -m "Wilson: Site [nom] créé pour [client]"
git push origin master
```

---

## ⚠️ Règles importantes

1. **Toujours faire `git pull` avant de modifier** → Évite les conflits
2. **Message de commit clair** → On sait qui a fait quoi
3. **Un seul agent modifie à la fois** → Si conflit, prévenir Jarbite
4. **Ne pas modifier les fichiers des autres agents** → Respect des rôles

---

## 🆘 En cas de problème

**Conflit de merge :**
```bash
# Si git pull affiche un conflit
git status
# Voir les fichiers en conflit
# Éditer les fichiers pour garder les bonnes données
git add .
git commit -m "Résolution de conflit"
git push origin master
```

**Mot de passe demandé :**
- Le token est déjà configuré
- Si ça demande un mot de passe, prévenir Jarbite

---

## 📊 Structure des fichiers

### `data/leads.csv`
```csv
ID,Nom,Type,Ville,Téléphone,Email,Site Web,Qualité,Statut
1,Restaurant XYZ,Restaurant,Cogolin,0123456789,email@test.com,Non,HIGH,nouveau
```

### `data/messages.csv`
```csv
ID,Lead ID,Message,Canal,Statut,Date
1,1,"Bonjour...",email,sent,2026-03-18
```

### `data/sites.csv`
```csv
ID,Client,Template,URL,Statut,Prix
1,Restaurant XYZ,restaurant,https://demo.com,livré,100
```

---

## ✅ Checklist avant chaque modification

- [ ] J'ai fait `git pull origin master`
- [ ] Je modifie le bon fichier
- [ ] J'ai testé mes changements
- [ ] Mon message de commit est clair
- [ ] J'ai fait `git push origin master`

---

**Questions ?** → Demander à Jarbite 👑
