# gitextractor 

the gitextractor extracts commits from multiple repos and developers for evaluation with skilld.ai 

gitextractor


  - it creates a directory under /opt/gitextractor
  - it creates a directory under /opt/gitextractor/repos where the repositories will be checked out

# installation

```
$ git clone git@github.com:SkilldAI/gitextractor.git
$ cd gitextractor
$ dpkg -i gitextractor.deb
```

---

# or build it by yourself / (expert mode)

First checkout the source

```
$ git clone git@github.com:SkilldAI/gitextractor.git
$ cd gitextractor
```

and then, well like I said - expert mode *g*


## package structure 

this is the structure of the package

<pre>
debpackage
│
├──── debsource
│     │
│     │
│     ├───── DEBIAN
│     │      │
│     │      └───── control
│     │
│     ├──── usr
│     │     │
│     │     ├───── share
│     │     │      │
│     │     │      │ 
│     │     │      ├───── man
│     │     │      │      │
│     │     │      │      └───── man8
│     │     │      │             │
│     │     │      │             └───── {packagename}.8.gz
│     │     │      │
│     │     │      └───── doc
│     │     │             │
│     │     │             └───── {packagename}
│     │     │                    │
│     │     │                    ├───── changelog.gz
│     │     │                    │
│     │     │                    └───── copyright
│     │     │
│     │     └───── bin - °16
│     │            │
│     │            └───── {packagename}
│     │
│     ├──── var
│     │     │
│     │     ├──── cache
│     │     │     │
│     │     │     └───── {packagename}
│     │     │
│     │     └──── log
│     │           │
│     │           └───── {packagename}
│     │
│     └──── etc
│           │
│           └──── {packagename}
│                 │
│                 └───── config.sh
│  
└───── debs
       │
       │
       ├───── keyfile
       │
       └───── dists
              │
              └───── stable
                     │
                     └───── {packagename}.deb
</pre>



## create a .deb package from debsource

```
$ fakeroot dpkg -b debsource debs/dists/stable/gitextractor.deb
```

## linting a deb package

```
$ lintian -i debs/dists/stable/gitextractor.deb
```

## gpg - signing - some basics

- create a key

```
$ gpg --gen-key

# choose 4096 bit
# never let it become invalid
# choose a good password
```


- list your keys
```
$ gpg --list-keys
```
<pre>
/home/jochen/.gnupg/pubring.gpg
-------------------------------
pub   4096R/A28A3C35 2017-08-18
uid                  Jochen Schultz <jschultz@php.net>
</pre>

- use a key hash to sign the deb package

```
$ sudo dpkg-sig --sign -k A28A3C35 gitextractor.deb
```

## set up a repository

> File: Packages

```
$ apt-ftparchive packages . > Packages
```

> File: Packages.gz

```
$ gzip -c Packages > Packages.gz
```

> File: InRelease

```
$ apt-ftparchive release . > Release
```

> File: Release

```
$ gpg --clearsign --default-key A28A3C35 -o InRelease Release
```

> File: Release.gpg

```
$  gpg --default-key A28A3C35 -abs -o Release.gpg Release
```

## find your ip

```
$ ifconfig 

or 

$ ip addr
```

## how to install the deb package on consumers machine 

```
$ sudo su
$ wget -O - http://ipaddrofkeyfilehost/keyfile | apt-key add -
$ echo "deb http://ipaddrofkeyfilehost/dists/stable /" >> /etc/apt/sources.list
$ apt update
$ apt install dtinstaller
$ exit
```

## note: this is not really marked as stable - but it doesn't delete anything or override anything unless you have anything in /opt/gitextractor - so it should be fine

## helper to set the right mods

```
# change all modes to 755
$ chmod -R 755 debsource

# change all files (not directories) to 644
$ find debsource -type f -exec chmod 644 -- {} +

# change all binaries to mode 755
$ chmod 755 debsource/usr/bin/*
```

> to do so we must make sure that all binaries are inside 
the correct folder






