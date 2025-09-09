# appleJuice Flatpak Repository

Der einfachste Weg, die `appleJuice` Programme auf einem Linux-System zu installieren, ist die Verwendung von Flatpak.

## Repository hinzufügen

```shell
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-add --if-not-exists applejuice https://applejuicenetz.github.io/flatpak/repo/applejuice.flatpakrepo
```

> [!IMPORTANT]  
> Es ist wichtig, dass Flathub als erstes Repository hinzugefügt wird um Abhängigkeiten korrekt aufzulösen.

Danach mit einem Tool der Wahl (z.B. GNOME Software, KDE Discover, etc.) nach `appleJuice` suche und installieren.
Meldung The App.. requires runtime org.freedesktop.Platform/aarch64/0.31.149.113

Die Programme sind dann im Anwendungsmenü in der Kategorie `Internet` zu finden.

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
