DESCRIPTION = "Sanitized set of 2.6 kernel headers for the C library's use."
SECTION = "devel"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

PR = "r1"

PACKAGE_ARCH = "${MACHINE_ARCH}"

DEPENDS += "unifdef-native"
RDEPENDS_${PN}-dev = ""
RRECOMMENDS_${PN}-dbg = "${PN}-dev (= ${EXTENDPV})"

INHIBIT_DEFAULT_DEPS = "1"
DEFAULT_PREFERENCE = "-1"

SRC_URI = "${KERNELORG_MIRROR}/pub/linux/kernel/v2.6/linux-${PV}.tar.bz2 \
           file://0001-implement-TIF_RESTORE_SIGMASK-support-and-enable-the.patch;patch=1 \
           file://dvbapi-5.3.patch;patch=1;pnum=1 \
"

SRC_URI[md5sum] = "84c077a37684e4cbfa67b18154390d8a"
SRC_URI[sha256sum] = "0acd83f7b85db7ee18c2b0b7505e1ba6fd722c36f49a8870a831c851660e3512"
  
S = "${WORKDIR}/linux-${PV}"

set_arch() {
	case ${TARGET_ARCH} in
		alpha*)   ARCH=alpha ;;
		arm*)     ARCH=arm ;;
		cris*)    ARCH=cris ;;
		hppa*)    ARCH=parisc ;;
		i*86*)    ARCH=i386 ;;
		ia64*)    ARCH=ia64 ;;
		mips*)    ARCH=mips ;;
		m68k*)    ARCH=m68k ;;
		powerpc*) ARCH=powerpc ;;
		s390*)    ARCH=s390 ;;
		sh*)      ARCH=sh ;;
		sparc64*) ARCH=sparc64 ;;
		sparc*)   ARCH=sparc ;;
		x86_64*)  ARCH=x86_64 ;;
	        avr32*)   ARCH=avr32 ;;
                bfin*)    ARCH=blackfin ;;
	esac
}

do_configure() {
	set_arch
	oe_runmake allnoconfig ARCH=$ARCH
}

do_compile () {
}

do_install() {
	set_arch
	oe_runmake headers_install INSTALL_HDR_PATH=${D}${exec_prefix} ARCH=$ARCH
	# Kernel should not be exporting this header
	rm -rf ${D}${includedir}/scsi

	# The ..install.cmd conflicts between various configure runs
	#find ${D}${includedir} -name ..install.cmd | xargs rm -f
}

BBCLASSEXTEND = "nativesdk"
