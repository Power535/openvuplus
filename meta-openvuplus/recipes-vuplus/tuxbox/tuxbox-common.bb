DESCRIPTION = "Tuxbox common files"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"
MAINTAINER = "Felix Domke <tmbinc@elitdvb.net>"

PN = "tuxbox-common"
PR = "r4"

SRC_REV = "8ef7a7f5f5df5f77197ad279e24b0dc454b8210b"

SRC_URI = "git://git.code.sf.net/p/tuxbox-cvs/cdk;protocol=git;tag=${SRC_REV} \
        http://dreamboxupdate.com/download/opendreambox/tuxbox-common-r11.tar.gz;name=tar \
        file://satellites_20130124.patch;patch=1;pnum=1 \
"
SRC_URI[tar.md5sum] = "b33829644e7d5be373edabffaf9803f2"
SRC_URI[tar.sha256sum] = "3399bb99a59acfcb12a48480d43934f989b0363cab5b5388341196cd5d2a1149"

FILES_${PN} = "/"

S = "${WORKDIR}/git/root_dream/share"

TRANSPONDER_LISTS = "satellites.xml terrestrial.xml"

do_install() {
	install -d ${D}/etc/tuxbox/
	install -d ${D}/usr/share/tuxbox
	install -m 0644 ${WORKDIR}/tuxbox-common-r11/scart.conf ${D}/etc/tuxbox/scart.conf
	install -m 0644 ${WORKDIR}/tuxbox-common-r11/timezone.xml ${D}/etc/tuxbox/timezone.xml
	ln -sf /etc/tuxbox/timezone.xml ${D}/etc/
	ln -sf /usr/share ${D}/share

	for i in ${TRANSPONDER_LISTS}; do
		install -m 0644 ${S}/tuxbox/$i ${D}/etc/tuxbox/$i
		ln -sf /etc/tuxbox/$i ${D}/etc/;
		ln -sf /etc/tuxbox/$i ${D}/usr/share/;
		ln -sf /etc/tuxbox/$i ${D}/usr/share/tuxbox/;
	done;
}
