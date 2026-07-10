# Triage des bug reports GameOn

Traite les rapports de bugs remontés in-app (table Supabase `bug_reports`, migration 023).

## Prérequis

La clé service role doit être disponible dans l'environnement : `SUPABASE_SERVICE_ROLE_KEY`
(Dashboard Supabase > Settings > API). Si elle est absente, demande à l'utilisateur de la
fournir via `export SUPABASE_SERVICE_ROLE_KEY=...` avant de continuer. Ne jamais l'écrire
dans un fichier du repo.

URL du projet : `https://jfhingwkrywnxtfapxsm.supabase.co`

## Étapes

1. **Récupérer les rapports ouverts** :
   ```bash
   curl -s "https://jfhingwkrywnxtfapxsm.supabase.co/rest/v1/bug_reports?status=eq.open&order=created_at.asc" \
     -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
     -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY"
   ```

2. **Pour chaque rapport**, dans l'ordre :
   - Lis la description, la catégorie, `app_version` et `platform`.
   - Vérifie dans le codebase si c'est un vrai bug (reproduis la logique, cherche le code
     concerné). Les `suggestion`/`other` sont à résumer pour l'utilisateur, pas à corriger
     d'office.
   - Si c'est un vrai bug : corrige-le, fais tourner `flutter analyze` et `flutter test`.
   - Mets à jour le statut :
     ```bash
     curl -s -X PATCH "https://jfhingwkrywnxtfapxsm.supabase.co/rest/v1/bug_reports?id=eq.<ID>" \
       -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
       -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
       -H "Content-Type: application/json" \
       -d '{"status": "fixed", "resolution_notes": "<explication courte>"}'
     ```
     Statuts possibles : `triaged` (vrai bug, pas encore corrigé), `in_progress`,
     `fixed`, `rejected` (pas un bug / pas reproductible — explique pourquoi dans
     `resolution_notes`).

3. **Résumé final** : liste chaque rapport traité avec son verdict (réel/non), le fix
   appliqué le cas échéant, et les suggestions à considérer. Ne commit pas sans accord.
