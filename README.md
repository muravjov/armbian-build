
# Banana Pi R64 + Armbian
This repo is a way to run [Armbian](https://www.armbian.com/) on [Banana Pi R64 sbc](http://www.banana-pi.org/r64.html).

## How to use it
You may use the already built latest image from [releases](https://github.com/muravjov/armbian-build/releases) or you may build it yourself like so:

```
sudo ./compile.sh WITHOUT_BUILD="yes" \
BOOTFS_TYPE="fat" BOARD="bananapir64" BRANCH="dev" RELEASE="buster" \
KERNEL_ONLY="no" KERNEL_CONFIGURE="no" BUILD_DESKTOP="no" BUILD_MINIMAL="yes"
```
This command line is just official documentation [states](https://github.com/armbian/build#build-parameter-examples)  except a few parameters:
* WITHOUT_BUILD="yes" - required. Because neither kernel, nor u-boot are being built but are prebuilt.
* KERNEL_LINK="link" - optional. By default points to latest kernel release of Frank's [repository](https://github.com/frank-w/BPI-R2-4.14/releases). May be http link or local file=deb package.

If you have questions please address youself to the forum [topic](http://forum.banana-pi.org/t/bpi-r64-armbian/10741/2).

