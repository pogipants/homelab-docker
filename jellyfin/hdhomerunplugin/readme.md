# https://github.com/stephenhoos/hdhomerun-jellyfin-guide

## install the runtimes for building
```bash 
sudo add-apt-repository ppa:dotnet/backports
  sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-9.0

 wget -qO- https://github.com/stephenhoos/hdhomerun-jellyfin-guide/archive/refs/tags/v0.3.2.0.tar.gz | tar -xvzf -

cd hdhomerun-jellyfin-guide-0.3.2.0

dotnet build Jellyfin.Plugin.HDHomeRunGuide/Jellyfin.Plugin.HDHomeRunGuide.csproj -c Release

mkdir -p /apps/runtime/jellyfin/config/plugins/HDHomeRun-Guide_0.3.2.0/

cp Jellyfin.Plugin.HDHomeRunGuide/bin/Release/net9.0/* /apps/runtime/jellyfin/config/plugins/HDHomeRun-Guide_0.3.2.0/

docker restart jellyfin
```

## Find the plugin in Jellyfin.

Set the IP to the HDHR tuner.

Don't put email or do anything for the paid subscription.

MORE TO ADD