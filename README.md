# appleJuice Flatpak Repository

Der einfachste Weg, die `appleJuice` Programme auf einem Linux-System zu installieren, ist die Verwendung von Flatpak.

## Repository hinzufügen

Das `appleJuice` Repository muss **immer** hinzugefügt werden, bevor die `appleJuice` Programme installiert werden können.

```shell
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-add --if-not-exists applejuice https://applejuicenetz.github.io/flatpak/repo/applejuice.flatpakrepo
```

> Es ist wichtig, dass das Flathub Repository hinzugefügt wird, um Abhängigkeiten korrekt aufzulösen.

## 1. installation im Desktop

Mit einem Tool der Wahl (z.B. `GNOME Software`, `KDE Discover`, etc.) nach `appleJuice` suchen.

Die `appleJuice` Programme sind nach der Installation im Anwendungsmenü in der Kategorie `Internet` zu finden.

## 2. installation über die Kommandozeile

> Dieser Schritt ist nur notwendig, wenn die Programme nicht wie in Schritt über den Desktop installiert wurden.

```shell
sudo flatpak install io.github.applejuicenetz.core//stable
sudo flatpak install io.github.applejuicenetz.javagui
sudo flatpak install io.github.applejuicenetz.collector
```

## Beta-Versionen

Die Beta-Version des **appleJuice Core** kann wie folgt installiert werden:

vorher die `stable` Version entfernen:

```shell
sudo flatpak remove io.github.applejuicenetz.core//stable
```

dann die `beta` Version installieren:

```shell
sudo flatpak install io.github.applejuicenetz.core//beta
```

## Repository aktualisieren

Dieses Repository baut keine Flatpak-Pakete mehr. `make sync-all` lädt fertige
`.flatpak`-Release-Assets von GitHub, importiert sie und signiert das Repository:

| Quellrepository | Asset-Präfix | Branch |
| --- | --- | --- |
| `applejuicenetz/core` | `AJCore` | `stable` für Releases, `beta` für Pre-Releases |
| `applejuicenetz/collector` | `AJCollector` | `stable` |
| `applejuicenetz/gui-java` | `AJCoreGUI` | `stable` |

Pro Release werden genau zwei Bundles benötigt: `amd64` / `x86_64` und
`aarch64` / `arm64`. Namen wie `AJCore-linux-amd64.flatpak` oder
`AJCore.0.31.150-aarch64.flatpak` werden unterstützt. Die Dateiendung ist `.flatpak`.
Hat das Core-Stable-Release keine `.flatpak`-Assets, bleibt `core//stable` auf dem
Stand des veröffentlichten Repositorys (`PUBLISHED_REPO_URL`, GPG-geprüft über
`repo/applejuice.gpg`) und wird dort für beide Architekturen übernommen. Sobald ein
Stable-Release Assets hat, ersetzt es diesen Stand. Fehlende einzelne oder mehrdeutige Assets brechen den Import ab; ältere Releases werden
nicht als Ersatz gewählt. Vor dem Import werden alle Bundles heruntergeladen
und vorhandene GitHub-SHA256-Digests geprüft.

Für Core werden der neueste reguläre Release und zusätzlich der neueste
Pre-Release verwendet, sofern er neuer als der Stable-Release ist. Der GitHub-Status
`prerelease` entscheidet über `//beta`, unabhängig vom Tag oder Bundle-Branch.
Gibt es kein neueres Pre-Release, folgt `core//beta` dem Stable-Release, damit
Beta-Nutzer weiter Updates erhalten und der Branch nicht verschwindet. Der Core-Workflow muss diese Assets zuerst
im Repository `applejuicenetz/core` veröffentlichen.

Voraussetzungen: `gh`, `jq`, `flatpak`, `ostree`, `gpg`, `sha256sum` und `make`.
`gh` benötigt eine Anmeldung oder `GH_TOKEN`. `GPG_KEY_FILE` bezeichnet den
privaten Signierschlüssel, `GPG_KEY` dessen Schlüssel-ID. Diese Werte können
über Umgebung oder `.env` gesetzt werden. `CORE_REPO`, `COLLECTOR_REPO` und
`JAVAGUI_REPO` erlauben alternative Quellrepositories.

Der Pages-Workflow synchronisiert manuell, wöchentlich und bei einem
`repository_dispatch` mit Event-Typ `flatpak-release`. Nachgelagerte
Release-Workflows können dieses Event auslösen, sobald beide Assets verfügbar
sind. Alte Manifeste und Update-Skripte unter `flatpak/` und `scripts/update-*`
werden vom Veröffentlichungsworkflow nicht mehr verwendet.
