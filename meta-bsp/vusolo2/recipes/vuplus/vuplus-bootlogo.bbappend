PR .= "-splash1"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " http://archive.vuplus.com/download/kernel/vmlinuz-initrd_${MACHINE}_20130212.tar.gz file://splash_cfe_auto.bin"

do_install_append() {
	install -m 0755 ${S}/vmlinuz-initrd-7346b0 ${D}/boot/initrd_cfe_auto.bin
        install -m 0755 ${S}/splash_cfe_auto.bin ${D}/boot/splash_cfe_auto.bin
}

SRC_URI[md5sum] = "3b45489e7902cbf98e9abdddea14567a"
SRC_URI[sha256sum] = "e7a7e747dcd7240c5d36c2235d11b2d0e703ed55be1120d6109220478d23fb09"

