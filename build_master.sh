#!/bin/bash
if [ ! "${1}" = "skip" ] ; then
	./build_clean.sh
	./build_kernel.sh CC='$(CROSS_COMPILE)gcc' "$@"
	./build_recovery.sh CC='$(CROSS_COMPILE)gcc' "$@"
fi

if [ -e boot.img ] ; then
	rm arter97-kernel-"$(git rev-parse --abbrev-ref HEAD)"-"$(cat version)".zip 2>/dev/null
	cp boot.img kernelzip/boot.img
	tail -n $(($(cat ramdisk/default.prop | wc -l) - $(grep -n "START OVERRIDE" ramdisk/default.prop | cut -d : -f 1) + 1)) ramdisk/default.prop > kernelzip/default.prop
	cd kernelzip/
	7z a -mx9 arter97-kernel-"$(git rev-parse --abbrev-ref HEAD)"-"$(cat ../version)"-tmp.zip *
	zipalign -v 4 arter97-kernel-"$(git rev-parse --abbrev-ref HEAD)"-"$(cat ../version)"-tmp.zip ../arter97-kernel-"$(git rev-parse --abbrev-ref HEAD)"-"$(cat ../version)".zip
	rm arter97-kernel-"$(git rev-parse --abbrev-ref HEAD)"-"$(cat ../version)"-tmp.zip
	cd ..
	ls -al arter97-kernel-"$(git rev-parse --abbrev-ref HEAD)"-"$(cat version)".zip
	rm kernelzip/boot.img
fi

if [ -e recovery.img ] ; then
	rm arter97-recovery-"$(cat version)"-philz_touch_"$(cat version_recovery | awk '{print $1}')".zip 2>/dev/null
	cp recovery.img recoveryzip/
	cd recoveryzip/
	sed -i -e s/PHILZ_VERSION/$(cat ../version_recovery | awk '{print $1}')/g -e s/CWM_VERSION/$(cat ../version_recovery | awk '{print $2 }')/g META-INF/com/google/android/updater-script
	7z a -mx9 arter97-recovery-"$(git rev-parse --abbrev-ref HEAD)"-"$(cat ../version)"-philz_touch_"$(cat ../version_recovery | awk '{print $1}')"-tmp.zip *
	zipalign -v 4 arter97-recovery-"$(git rev-parse --abbrev-ref HEAD)"-"$(cat ../version)"-philz_touch_"$(cat ../version_recovery | awk '{print $1}')"-tmp.zip ../arter97-recovery-"$(git rev-parse --abbrev-ref HEAD)"-"$(cat ../version)"-philz_touch_"$(cat ../version_recovery | awk '{print $1}')".zip
	rm arter97-recovery-"$(git rev-parse --abbrev-ref HEAD)"-"$(cat ../version)"-philz_touch_"$(cat ../version_recovery | awk '{print $1}')"-tmp.zip
	sed -i -e s/$(cat ../version_recovery | awk '{print $1}')/PHILZ_VERSION/g -e s/$(cat ../version_recovery | awk '{print $2 }')/CWM_VERSION/g META-INF/com/google/android/updater-script
	cd ..
	ls -al arter97-recovery-"$(git rev-parse --abbrev-ref HEAD)"-"$(cat version)"-philz_touch_"$(cat version_recovery | awk '{print $1}')".zip
	rm recoveryzip/recovery.img
	fakeroot tar -H ustar -c recovery.img > arter97-recovery-"$(git rev-parse --abbrev-ref HEAD)"-"$(cat version)"-philz_touch_"$(cat version_recovery | awk '{print $1}')".tar
	md5sum -t arter97-recovery-"$(git rev-parse --abbrev-ref HEAD)"-"$(cat version)"-philz_touch_"$(cat version_recovery | awk '{print $1}')".tar >> arter97-recovery-"$(git rev-parse --abbrev-ref HEAD)"-"$(cat version)"-philz_touch_"$(cat version_recovery | awk '{print $1}')".tar
	mv arter97-recovery-"$(git rev-parse --abbrev-ref HEAD)"-"$(cat version)"-philz_touch_"$(cat version_recovery | awk '{print $1}')".tar arter97-recovery-"$(git rev-parse --abbrev-ref HEAD)"-"$(cat version)"-philz_touch_"$(cat version_recovery | awk '{print $1}')".tar.md5
fi
