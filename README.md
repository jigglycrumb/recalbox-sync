# recalbox-sync

Sync Recalbox to your NAS.

## Prerequisites

A remote rsync server with a module to sync to. I use OpenMediaVault and its rsync extension for this.

## Basic installation

This will enable sync on boot/shutdown and approx. once an hour

1. Copy `custom.sh` and `recalbox-sync.sh` to `/recalbox/share/system`

2. Edit `REMOTE` in `recalbox-sync.sh` to match your rsync server. Optionally check `RSYNC_OPTS` if you want to change anything

3. `reboot` or continue with...

## Advanced installation

This will enable triggering the sync (as well as any other shell script) from the menu

1. Copy the `scripts` folder to `/recalbox/share/system/`

2. Remount the root filesystem read-write: `mount -o rw,remount /`

3. Copy `themes/scripts` to `/recalbox/share_init/system/.emulationstation/themes/recalbox-next/`

4. Edit `/recalbox/share_init/system/.emulationstation/es_systems.cfg` and add a new system to the menu:

```
  <system>
    <fullname>Scripts</fullname>
    <name>scripts</name>
    <path>/recalbox/share/system/scripts</path>
    <extension>.sh</extension>
    <command>/bin/sh %ROM%</command>
    <theme>scripts</theme>
  </system>
```

5. Restart emulationstation `/etc/init.d/S31emulationstation restart` or `reboot`
