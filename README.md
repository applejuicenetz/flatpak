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
