# appleJuice Flatpak Repository

Der einfachste Weg, die `appleJuice` Programme auf einem Linux-System zu installieren, ist die Verwendung von Flatpak.

## Repository hinzufügen

Das `appleJuice` Repository muss immer hinzugefügt werden, bevor die `appleJuice` Programme installiert werden können.

```shell
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-add --if-not-exists applejuice https://applejuicenetz.github.io/flatpak/repo/applejuice.flatpakrepo
```

> Es ist wichtig, dass das Flathub Repository hinzugefügt wird, um Abhängigkeiten korrekt aufzulösen.

## 1. installation im Desktop

Mit einem Tool der Wahl (z.B. `GNOME Software`, `KDE Discover`, etc.) nach `appleJuice` suchen.

Die Programme sind nach der Installation im Anwendungsmenü in der Kategorie `Internet` zu finden.

## 2. installation über die Kommandozeile

```shell
sudo flatpak install applejuice io.github.applejuicenetz.core
sudo flatpak install applejuice io.github.applejuicenetz.javagui 
sudo flatpak install applejuice io.github.applejuicenetz.collector
```

## 3. standalone installation ohne Repository

```shell
sudo flatpak install https://applejuicenetz.github.io/flatpak/repo/core.flatpakref
sudo flatpak install https://applejuicenetz.github.io/flatpak/repo/javagui.flatpakref
sudo flatpak install https://applejuicenetz.github.io/flatpak/repo/collector.flatpakref
```
