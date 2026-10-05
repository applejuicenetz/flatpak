# appleJuice Flatpak: Wartung und Agenten-Anweisungen

## Zweck und Dokumentation

Dieses Repository veröffentlicht das signierte appleJuice-Flatpak-Repository über GitHub Pages. Es baut keine Anwendungspakete: Fertige `.flatpak`-Bundles kommen aus den Release-Repositories der Anwendungen.

- `README.md` ist deutschsprachige Nutzer-Dokumentation für Installation, Start und Updates.
- Architektur, Build- und Veröffentlichungsabläufe sowie Wartungshinweise gehören in diese `AGENTS.md`.
- Produktname: **appleJuice**; Organisation: **appleJuiceNETZ**. Technische IDs und URLs bleiben unverändert.
- Vor Änderungen Git-Status und Branch prüfen; bestehende Änderungen erhalten. Ohne Auftrag weder committen noch pushen.

## Aktive Dateien

- `scripts/import-bundles.sh`: Release-Auswahl, Bundle-Download, Digest-Prüfung und Import.
- `Makefile`: Repository initialisieren, Signierschlüssel importieren, Bundles importieren, Repository signieren und Referenzen auflisten.
- `.github/workflows/build-flatpak.yml`: Synchronisierung und Pages-Veröffentlichung.
- `repo/applejuice.flatpakrepo`, `repo/applejuice.gpg`, `repo/applejuice.png`: öffentliche Repository-Konfiguration, öffentlicher GPG-Schlüssel und Icon; für Veröffentlichung erhalten.
- `Dockerfile`: Debian-Trixie-Umgebung mit Repository-Werkzeugen, Arbeitsverzeichnis `/workdir`.
- `.run/flatpak-builder.run.xml`: IDE-Konfiguration für Docker und `make sync-all`.

Paketänderungen gehören in die jeweiligen Quellrepositories.

## Release-Quellen und Auswahl

| Quelle | App-ID | Asset-Präfix | Zielbranch |
| --- | --- | --- | --- |
| `applejuicenetz/core` | `io.github.applejuicenetz.core` | `AJCore` | `stable` und `beta` |
| `applejuicenetz/collector` | `io.github.applejuicenetz.collector` | `AJCollector` | `stable` |
| `applejuicenetz/gui-java` | `io.github.applejuicenetz.javagui` | `AJCoreGUI` | `stable` |

Für jeden importierten Release sind genau zwei Bundles erforderlich: `amd64`/`x86_64` und `aarch64`/`arm64`. Unterstützte Namen sind beispielsweise `AJCore-linux-amd64.flatpak` und `AJCore.0.31.150-aarch64.flatpak`. Der Präfix muss von `.` oder `-` gefolgt sein; Architektur steht unmittelbar vor `.flatpak`.

- Core-Stable verwendet den neuesten regulären GitHub-Release.
- Hat dieser keine `.flatpak`-Assets, werden beide veröffentlichten Stable-Referenzen aus `PUBLISHED_REPO_URL` übernommen. Deren GPG-Signaturen werden mit `PUBLISHED_GPG_FILE` geprüft.
- Core-Beta verwendet den neuesten nicht als Entwurf markierten Pre-Release, dessen `published_at` neuer als der Stable-Release ist. `prerelease` entscheidet, nicht Tagname oder Bundle-Branch.
- Ohne neueren Pre-Release folgt Beta dem Stable-Release, sofern dieser Flatpak-Assets besitzt. Ohne solche Assets werden keine Beta-Bundles importiert.
- Collector und Java-GUI verwenden jeweils den neuesten regulären Release.
- Fehlende einzelne oder mehrdeutige Assets brechen den Import ab; ältere Releases dienen nicht als Ersatz.
- Vor Bundle-Import werden alle ausgewählten Bundles heruntergeladen und vorhandene GitHub-SHA256-Digests geprüft. Stable-Übernahmen aus dem veröffentlichten Repository erfolgen vorher und können das Zielrepository bereits verändern.
- Bundle-Import erfolgt zuerst in ein temporäres Staging-Repository, danach mit expliziter Zielreferenz und Signatur ins Zielrepository.

## Lokale Synchronisierung

Benötigte Werkzeuge: `bash`, `gh`, `jq`, `flatpak`, `ostree`, `gpg`, `sha256sum` und `make`. `gh` benötigt Anmeldung oder `GH_TOKEN`.

`GPG_KEY_FILE` bezeichnet die private Signierschlüsseldatei, `GPG_KEY` deren Schlüssel-ID. Make liest eine vorhandene `.env` ein und exportiert ihre Werte. Geheimnisse nicht lesen, ausgeben oder committen; private Schlüssel und `.env` nicht für Dokumentationsprüfungen öffnen.

Mit eingerichteter Umgebung:

```shell
make sync-all
```

Reihenfolge: `repo-init`, `gpg-key-import`, `import-bundles`, `repo-sign`, `repo-list`. `repo-sign` signiert Commits und aktualisiert die Repository-Zusammenfassung mit Defaultbranch `stable` und Pruning.

Konfigurierbare Variablen:

- `CORE_REPO`, `COLLECTOR_REPO`, `JAVAGUI_REPO`: alternative Release-Repositories.
- `REPO_DIR`: Import-Ziel des Skripts; Make-Ziele initialisieren und signieren weiterhin `./repo/`. Für abweichende Ziele den vollständigen Ablauf explizit anpassen.
- `PUBLISHED_REPO_URL`: standardmäßig `https://applejuicenetz.github.io/flatpak/repo/`.
- `PUBLISHED_GPG_FILE`: standardmäßig `repo/applejuice.gpg` relativ zum Projektroot.

Synchronisierung benötigt Netzwerk und privaten Signierschlüssel, verändert das Repository und ist kein harmloser Dokumentationstest.

## GitHub Pages

Workflow-Auslöser: manuell über `workflow_dispatch` und über `repository_dispatch` mit Typ `flatpak-release`.

Release-Workflows der Anwendungen können `flatpak-release` auslösen, sobald beide Architektur-Bundles verfügbar sind. Workflow verwendet `GH_TOKEN`, Variable `FLATPAK_GPG_KEY` für die Schlüssel-ID und gleichnamiges Secret für den privaten Schlüssel. Schlüsseldatei und temporäres GPG-Verzeichnis werden auch bei Fehlern entfernt.

Nach erfolgreicher Synchronisierung werden README und `repo/` als Pages-Inhalt bereitgestellt. README wird über die GitHub-Markdown-API zu `index.html` gerendert. Separater Deploy-Job veröffentlicht das Pages-Artefakt. Dokumentationsänderungen allein lösen keine Veröffentlichung aus.

## Prüfungen

Für Dokumentations- und Bereinigungsänderungen:

```shell
git diff --check
bash -n scripts/import-bundles.sh
```

Zusätzlich Dateiverweise in versionierten Dateien auf gültige Ziele prüfen; `.env` und private Schlüssel ausschließen. Makefile bei Prüfungen ohne Signierung nicht ausführen, da es `.env` einliest. Für Änderungen am Importverhalten isolierte Tests mit echten Test-Bundles und Testschlüssel oder kontrollierte Release-Synchronisierung durchführen. Syntaxprüfung allein belegt weder erfolgreichen Import noch Veröffentlichung.
