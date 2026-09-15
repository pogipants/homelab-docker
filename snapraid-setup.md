# install snapraid
apt update
apt install snapraid

# create mount dirs
mkdir -p /mnt/{disk1 disk2 disk3 disk4 disk5}


mkfs.ext4 /dev/sdb - 3045eccd-36c5-4446-b0fd-e6e071066a6b
mkfs.ext4 /dev/sdf - 5fe38bce-5f21-4280-8344-1e093d00a8bc
mkfs.ext4 /dev/sde - 2099ae7f-f03e-49bb-8c2f-94bf872aca98


# add to fstab. Look at other disks and mount with the UUID, not just the drive sdX

# /etc/snapraid.conf

```text
# Parity disk
parity /mnt/disk1/snapraid.parity

# Content files (recommended on all disks)
#content /mnt/disk1/snapraid.content
content /mnt/disk2/snapraid.content
content /mnt/disk3/snapraid.content
#content /mnt/disk4/snapraid.content

# Data disks
#data d1 /mnt/disk1/
data d2 /mnt/disk2/
data d3 /mnt/disk3/
```

# now run snapraid sync
```bash
snapraid sync

snapraid status


```

# add 5th disk later to /etc/snapraid.conf
```text
data d4 /mnt/disk5/
content /mnt/disk5/snapraid.content
```

```bash
snapraid sync
```


apt install mergerfs

mkdir /mnt/mergeddisk

# add to /etc/fstab

/mnt/disk1:/mnt/disk2:/mnt/disk3 /mnt/mergeddisk fuse.mergerfs defaults,allow_other,use_ino,category.create=epmfs 0 0


