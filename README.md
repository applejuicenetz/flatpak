# appleJuice Flatpak-Repository

Über dieses Repository installierst du appleJuice unter Linux mit Flatpak:

- **appleJuice Core:** Client für Downloads und Uploads.
- **Java-GUI:** grafische Oberfläche für den Core.
- **Information Collector:** Werkzeug zum Sammeln von Core-Informationen.

## Voraussetzungen

Flatpak muss installiert sein. Nutze dafür die Paketverwaltung deiner Linux-Distribution.
Flathub stellt benötigte Laufzeitumgebungen bereit; das appleJuice-Repository stellt die Anwendungen bereit.

## Repositories hinzufügen

Die folgenden Befehle richten beide Repositories für deinen Benutzer ein. Dafür ist kein `sudo` nötig:

```shell
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --user --if-not-exists applejuice https://applejuicenetz.github.io/flatpak/repo/applejuice.flatpakrepo
```

## Installation

Suche in GNOME Software oder KDE Discover nach appleJuice und installiere die gewünschten Anwendungen. Nach der Installation findest du sie im Anwendungsmenü unter Internet.

Alternativ installierst du sie über die Kommandozeile:

```shell
flatpak install --user applejuice io.github.applejuicenetz.core//stable
flatpak install --user applejuice io.github.applejuicenetz.javagui//stable
flatpak install --user applejuice io.github.applejuicenetz.collector//stable
```

## Anwendungen starten

Starte die Anwendungen über das Anwendungsmenü oder mit:

```shell
flatpak run io.github.applejuicenetz.core
flatpak run io.github.applejuicenetz.javagui
flatpak run io.github.applejuicenetz.collector
```

Die Java-GUI benötigt einen laufenden Core.

## Core-Beta verwenden

Zum Wechsel auf den Beta-Kanal entfernst du zuerst die installierte Stable-Version und installierst dann die Beta-Version:

```shell
flatpak uninstall --user io.github.applejuicenetz.core//stable
flatpak install --user applejuice io.github.applejuicenetz.core//beta
```

Zurück zum Stable-Kanal:

```shell
flatpak uninstall --user io.github.applejuicenetz.core//beta
flatpak install --user applejuice io.github.applejuicenetz.core//stable
```

## Updates installieren

```shell
flatpak update --user
```

Dieser Befehl aktualisiert auch andere Flatpak-Anwendungen deines Benutzers.
