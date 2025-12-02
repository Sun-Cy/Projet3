# Rapport de projet

Technologie utilisée : Godot 4.5
Principale découverte : Godot et le multijoueur

L'intelligence artificielle a été utilisée pour aider à la programmation et à la recherche de fonctionnalités. De plus, il a été utilisé pour comprendre des processus clés comme les RPC et les callbacks.

Le potentiel de Godot 4.5 est énorme, à chaque mise à jour, ils ajoutent une grande quantité de fonctionnalités et des améliorations. Il est très facile d'apprendre et de commencer à développer des jeux avec Godot, car il utilise une syntaxe simple et intuitive similaire à Python. Il est également très rapide et facile à utiliser, car il est conçu pour être utilisé par des débutants.

Godot est aussi très léger, il s'agit d'un simple fichier binaire de 363 MO sur Mac et 155 Mo sur Windows. Il est également très versatile, il créer des jeux pour Mac, Windows, Linux, Android et iOS et même des applications web. On peut l'utiliser pour faire des jeux, mais aussi des applications, des outils et des applications de bureau.

## Apprentissage de Mathys
J'ai scindé mon apprentissage en deux parties. La première partit, j'ai tenté de commencer à programmer sans utiliser d'intelligence artificielle autre que pour comprendre le code ou la documentation. L’intelligence artificielle me servait d’assistant simplement. La deuxième partit, j'ai utilisé l'intelligence artificielle pour aider à la programmation et à la recherche de fonctionnalités.

## Apprentissage de Cedrik
Le plus grand apprentissage que j'ai fait était sur la difficulter de faire du multiplayer a temps reele. Un exemple est j'ai passer environt 2 heures pour ajouter un item qui peu couper des arbres. J'ai ensuite passer 2 jours pour comprendre le systeme multiplayer et synchroniser le dommage et la destruction des arbres.

### Constat
J'ai constaté que l'intelligence artificielle est très utile pour aider à la programmation et à la recherche de fonctionnalités. Elle est aussi très utile pour comprendre le code et la documentation. Ma productivité a été grandement améliorée, mais j'ai aussi constaté que l'intelligence artificielle fait souvent des erreurs que je dois corriger manuellement ou bien supprimer ce qu'elle a fait et recommencer au complet.


# New
# Rapport de projet – Exploration de Godot 4.5 avec l’IA

## 1. Contexte du projet

Dans le cadre du projet « Explorer une technologie à l’aide de l’intelligence artificielle », notre équipe de deux personnes (Mathys et Cedrik) a choisi d’explorer le moteur de jeu **Godot 4.5**, avec un accent particulier sur le **multijoueur en temps réel** et l’utilisation de l’IA comme assistant de développement.:contentReference[oaicite:0]{index=0}  

L’objectif était :
- de comprendre en profondeur le fonctionnement du multijoueur dans Godot (RPC, autorité, synchronisation des états),
- de réaliser un prototype jouable en 2D,
- et de documenter l’apport réel de l’IA (ChatGPT, Copilot, etc.) dans notre processus de travail.

Nous avons tenu un **journal de bord hebdomadaire (journal.md)** qui retrace les tâches réalisées, l’usage de l’IA, ainsi que les difficultés rencontrées.:contentReference[oaicite:1]{index=1}  

---

## 2. Technologie explorée : Godot 4.5 et le multijoueur

### 2.1. Aperçu de Godot 4.5

Godot 4.5 est un moteur de jeu libre et multiplateforme, avec un langage de script principal, **GDScript**, dont la syntaxe est proche de Python. Cela le rend particulièrement accessible pour débuter : la courbe d’apprentissage est raisonnable et la productivité augmente rapidement.

Principales caractéristiques que nous avons exploitées :

- **GDScript** : syntaxe claire et concise, idéale pour prototyper rapidement des mécaniques.
- **Scènes et nœuds** : architecture orientée composants (nodes + scripts), très flexible pour structurer un jeu 2D.
- **Export multiplateforme** : possibilité de cibler Windows, macOS, Linux, Android, iOS et le Web.
- **Légèreté** : l’éditeur reste relativement léger et simple à installer, ce qui facilite le travail en équipe sur différents postes.

### 2.2. Multijoueur en temps réel dans Godot

La principale découverte technique concerne le **multijoueur** :

- Utilisation de **RPC** (Remote Procedure Calls) pour synchroniser des actions entre le serveur et les clients (ex. : coupe d’arbres, destruction d’objets, ouverture de coffres).
- Gestion de l’**autorité réseau** (`multiplayer_authority`) sur les nœuds joueurs et les entités, pour éviter les conflits entre clients.
- Expérimentation des **MultiplayerSynchronizer** et des bonnes pratiques de synchronisation (états, position, santé, inventaire).
- Compréhension des difficultés liées au **temps réel** : latence, désynchronisations et propagation des changements dans la scène.

---

## 3. Prototype réalisé

Nous avons développé un **prototype de jeu 2D multijoueur** avec les éléments suivants (synthèse basée sur le journal de bord):contentReference[oaicite:2]{index=2} :

### 3.1. Fonctionnalités principales

- **Menu principal et options**  
  - Création du menu principal et du menu d’options (résolution, VSync, audio, etc.).  
  - Intégration d’un bouton *Play* qui lance la scène de jeu.  

- **Scène de jeu et joueur**
  - Ajout d’un joueur avec animations (déplacement, idle, etc.).
  - Gestion du déplacement avec correction de la **vitesse en diagonale**.
  - Mise en place d’un **YSort** pour le rendu correct des entités en 2D.

- **Carte et environnement**
  - Création et refonte de la carte avec **tileset**, collisions et falaises.
  - Ajout d’un overlay autour des tiles pour permettre l’interaction (ex. : arbres, coffre, crate).

- **Système de composants**
  - Composant de **santé** et **dommages** pour les arbres et autres entités.
  - Animations de dommages et de mort des arbres.
  - Introduction d’un système de **component** pour pouvoir réutiliser la logique (damage, interaction, inventaire, etc.).

- **Inventaire et interface**
  - Ajout d’un **inventaire** et d’un **UI de hotbar** (barre rapide).
  - Intégration d’une hache dans l’inventaire par défaut.
  - Synchronisation de la disparition du coffre avec le multijoueur.

- **Multijoueur**
  - Mise en place d’un système **peer-to-peer** (serveur/client) avec plusieurs joueurs.
  - Caméra indépendante par joueur.
  - Synchronisation de la coupe d’arbres et de la destruction des entités en réseau.
  - Debug overlay (F3) pour suivre l’état du multijoueur.

### 3.2. Rôle de l’IA dans le prototype

Tout au long du développement, l’IA a été utilisée pour :

- proposer des structures de menus et d’UI,
- générer ou corriger des scripts GDScript,
- expliquer des concepts comme les RPC, le système de multijoueur, le fonctionnement de la VSync multi-écran,
- suggérer des architectures de composants (DamageComponent, InteractionComponent, InventoryComponent),
- aider à déboguer des problèmes de désynchronisation.

---

## 4. Utilisation de l’IA : méthodologie et retour d’expérience

Conformément aux consignes, l’IA a été utilisée comme **outil d’aide**, et non comme simple générateur de contenu.  

### 4.1. Phase 1 – IA comme assistant de compréhension (Mathys)

Mathys a d’abord travaillé avec une approche en deux étapes :

1. **Sans IA pour l’écriture du code**, mais en s’autorisant à l’utiliser pour :
   - comprendre des extraits de documentation,
   - clarifier des fonctions spécifiques (ex. `normalized()` sur les vecteurs),
   - vérifier la logique de certaines parties du code.

2. **Avec IA pour accélérer la production**, une fois les bases comprises :
   - génération de bouts de code pour le multijoueur (création serveur/client, caméras par joueur),
   - assistance pour la mise en place du YSort et de l’overlay d’interaction,
   - aide sur la conception de l’interface d’inventaire et de la hotbar.

Cette approche a permis de rester actif dans le raisonnement tout en profitant de l’IA pour gagner du temps sur la recherche et la syntaxe.

### 4.2. Phase 2 – IA comme copilote de développement (Cedrik)

Cedrik a surtout utilisé l’IA comme **copilote** sur des tâches concrètes :

- conception du **menu principal** et du **menu d’options** avec hiérarchie recommandée par l’IA,
- réglage des **paramètres d’application** (VSync, FPS, audio) à partir de morceaux de code fournis par l’IA,
- implémentation du système de **damage et destruction d’arbres** en multijoueur,
- création d’un **composant d’interaction** générique, en demandant « la meilleure façon » de structurer ce composant,
- compréhension du fonctionnement de **VSync sur plusieurs moniteurs**,
- mise en place du **rebinding des contrôles** et de la réorganisation des fichiers.

Cependant, plusieurs erreurs ont dû être corrigées :

- mauvais chemins de ressources dans le code généré,
- exemples de multijoueur ne correspondant pas exactement à l’architecture de notre projet,
- approximations sur certaines API de Godot (ex. paramètres de fonctions, options VSync).

Cela confirme que l’IA est un **accélérateur**, mais pas une source de vérité fiable à 100 %.

---

## 5. Apprentissages individuels

### 5.1. Apprentissage de Mathys

Mathys a structuré son apprentissage en deux parties.

Dans la première partie, il a surtout utilisé l’IA :

- pour **comprendre la documentation** ou des extraits de code,
- pour découvrir des fonctions utiles (comme `normalized()` pour la gestion du mouvement),
- comme outil de vulgarisation sur les concepts de multijoueur.

Dans la deuxième partie, l’IA a été intégrée plus directement dans le flux de travail :

- génération de scripts de base pour le multijoueur,
- aide à la mise en place de la **caméra par joueur**,
- assistance sur la **hotbar** et l’intégration de l’inventaire,
- suggestions de corrections pour les problèmes de vitesse en diagonale et d’interaction avec les coffres.

Mathys en retire que l’IA est très efficace pour réduire le temps passé à chercher des exemples ou des solutions, à condition de **valider systématiquement** le code retourné.

### 5.2. Apprentissage de Cedrik

Pour Cedrik, le plus grand apprentissage concerne la **complexité réelle du multijoueur en temps réel**.

Un exemple marquant :
- ajouter un item pour couper des arbres a pris **environ 2 heures**;
- mais comprendre le système multijoueur, synchroniser les dégâts et la destruction des arbres a pris **2 jours complets**.

Les principaux enseignements :

- le multijoueur ne se résume pas à « ajouter un RPC », mais implique de réfléchir à l’autorité, à la fréquence de synchronisation, et aux états des entités côté client et serveur;
- il est facile de créer des **désynchronisations** (arbres visibles détruits d’un côté, mais encore présents de l’autre);
- l’IA peut expliquer les concepts, mais les **tests en conditions réelles** restent indispensables.

Cedrik a aussi beaucoup appris sur :

- l’organisation d’un projet Godot (arborescence, composants),
- la gestion du **VSync** et des performances,
- la mise en place d’un système générique d’interaction et d’inventaire.

---

## 6. Bilan critique : Godot 4.5 et l’IA

### 6.1. Potentiel et limites de Godot 4.5

**Points forts :**

- Facile à prendre en main grâce à GDScript et à l’interface de l’éditeur.
- Architecture par scènes et nœuds très flexible pour expérimenter.
- Fonctionnalités 2D robustes (YSort, TileMap, collisions, animations).
- Support intégré du multijoueur, même si complexe, avec RPC et outils dédiés.

**Limites rencontrées :**

- Le multijoueur demande une compréhension fine de concepts tels que l’**autorité**, la **latence**, et la **synchronisation d’état**.
- Certains cas concrets (par ex. synchronisation d’arbres destructibles ou d’objets d’inventaire) nécessitent beaucoup de tests et de débogage.
- La documentation est bonne, mais certains scénarios avancés manquent d’exemples directement applicables à notre architecture.

### 6.2. Potentiel et limites de l’IA dans ce contexte

**Apports positifs :**

- Accélération de la recherche (exemples de code, explications de concepts).
- Aide à la conception (structure de menus, composants, architecture de scripts).
- Support au débogage : proposer des pistes pour résoudre des bugs de synchronisation ou de collisions.
- Inspiration pour de nouvelles fonctionnalités (debug overlay, composants réutilisables, etc.).

**Limites observées :**

- L’IA génère régulièrement du code **partiellement erroné** : mauvais chemins, légère différence d’API, oubli de cas particuliers.
- Certains exemples de multijoueur sont trop génériques et ne tiennent pas compte de la structure réelle du projet.
- Risque de dépendance : il faut résister à la tentation de « tout demander à l’IA » sans réfléchir.

En pratique, nous avons dû :

- tester systématiquement tout code généré,
- comparer les réponses de l’IA à la documentation officielle,
- parfois **supprimer complètement** une solution proposée et repartir de zéro.

---

## 7. Conclusion

Ce projet nous a permis :

- d’acquérir une **expérience concrète** avec Godot 4.5, en particulier sur le multijoueur en temps réel;
- de réaliser un **prototype jouable** incluant menus, map, animations, système de composants, inventaire, hotbar et coupe d’arbres en réseau;
- de développer une **réflexion critique** sur l’utilisation de l’IA en développement logiciel.

Nous retenons que :

- Godot 4.5 est un moteur très accessible et puissant pour le 2D, mais le multijoueur reste un sujet avancé qui demande du temps et de la rigueur.
- L’IA, utilisée comme **partenaire d’analyse, de conception et de débogage**, peut considérablement augmenter la productivité.
- Cependant, l’IA ne remplace ni la compréhension des concepts, ni les tests, ni le jugement humain : elle doit rester un **outil d’aide**, pas un pilote automatique.

Ce projet répond ainsi aux objectifs de la consigne : exploration d’une technologie émergente, mise en pratique via un prototype, utilisation réfléchie de l’IA et production d’une synthèse critique documentée.  

