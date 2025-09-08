# appleJuice Flatpak Repository

Der einfachste Weg, die `appleJuice` Programme auf einem Linux-System zu installieren, ist die Verwendung von Flatpak.

## Repository hinzufügen

```shell
sudo flatpak remote-add --if-not-exists applejuice https://applejuicenetz.github.io/flatpak/repo/applejuice.flatpakrepo
```

Danach mit einem Tool der Wahl (z.B. GNOME Software, KDE Discover, etc.) nach `appleJuice` suche und installieren.

## 1. alternative über ein Terminal installieren

```shell
sudo flatpak install applejuice io.github.applejuicenetz.core
sudo flatpak install applejuice io.github.applejuicenetz.javagui 
sudo flatpak install applejuice io.github.applejuicenetz.collector
```

## 2. alternative installation ohne Repository

```shell
sudo flatpak install https://applejuicenetz.github.io/flatpak/repo/core.flatpakref
sudo flatpak install https://applejuicenetz.github.io/flatpak/repo/javagui.flatpakref
sudo flatpak install https://applejuicenetz.github.io/flatpak/repo/collector.flatpakref
```
