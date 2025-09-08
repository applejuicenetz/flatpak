# appleJuice Flatpak Repository

## add appleJuice Flatpak repository

```shell
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --if-not-exists applejuice https://applejuicenetz.github.io/flatpak/repo/applejuice.flatpakrepo
```

## install appleJuice

```shell
flatpak install applejuice org.applejuicenetz.core 
flatpak install applejuice org.applejuicenetz.gui 
flatpak install applejuice org.applejuicenetz.collector
```

## development environment setup

### install dependencies

```shell
sudo flatpak install flathub org.freedesktop.Sdk.Extension.openjdk21/aarch64/24.08
sudo flatpak install flathub org.freedesktop.Sdk.Extension.openjdk21/amd64/24.08
```
