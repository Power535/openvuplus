DESCRIPTION = "Additional plugins for Enigma2"
MAINTAINER = "Felix Domke <tmbinc@elitedvb.net>"
LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://COPYING;md5=8e37f34d0e40d32ea2bc90ee812c9131"

PACKAGES_DYNAMIC = "enigma2-plugin-*"

# if you want experimental, use:
#SRCREV="87fd2f1120962f553ecb1a88bbee46ed821df975"
SRCREV="c8fc96e8e51e1ef71e1709f9dd6f733007f9463e"
SRCDATE="20110215"
BRANCH="master"
PV = "experimental-git${SRCDATE}"
PR = "r10"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI="git://code.vuplus.com/git/dvbapp-plugin.git;protocol=git;branch=${BRANCH};tag=${SRCREV}"

EXTRA_OECONF = " \
        BUILD_SYS=${BUILD_SYS} \
        HOST_SYS=${HOST_SYS} \
        STAGING_INCDIR=${STAGING_INCDIR} \
        STAGING_LIBDIR=${STAGING_LIBDIR} \
"

SRC_URI_append_vuplus = " \
	   file://enigma2_plugins_mytube_tpm.patch;patch=1;pnum=1 \
	   file://enigma2_plugins_20121113.patch;patch=1;pnum=1 \
	   file://enigma2_plugins_webinterface_tpm.patch;patch=1;pnum=1 \
	   file://enigma2_plugins_ac3lipsync_dolby.patch;patch=1;pnum=1 \
	   file://enigma2_plugins_autoresolution_fix.patch;patch=1;pnum=1 \
	   file://enigma2_plugins_fancontrol2.patch;patch=1;pnum=1 \
	   file://enigma2_plugins_gst_plugins_pkgname.patch;patch=1;pnum=1 \
           file://dreamboxweb.png \
           file://dreamboxwebtv.png \
           file://favicon.ico \
	   file://Makefile.am "

FILES_${PN} += " /usr/share/enigma2 /usr/share/fonts "
FILES_${PN}-meta = "${datadir}/meta"
PACKAGES += "${PN}-meta"
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit autotools

S = "${WORKDIR}/git"

DEPENDS = "python-pyopenssl python-gdata streamripper python-mutagen python-daap"
DEPENDS += "enigma2"

def modify_po():
	import os
	try:
		os.system("find ./ -name \"*.po\" > ./po_list")
		os.system("find ./ -name \"*.pot\" >> ./po_list")
		po_list = []
		po_list = open('po_list','r+').readlines()
		for x in po_list:
			changeword1(x)
		changeword1('enigma2-plugins/networkwizard/src/networkwizard.xml ')
		changeword2('enigma2-plugins/webinterface/src/web-data/tpl/default/index.html ')
		os.system('rm po_list')
	except:
		print 'word patch error '
		return

def changeword1(file):
	fn = file[:-1]
	fnn = file[:-1]+'_n'
	cmd = "sed s/Dreambox/STB/g "+fn+" > "+fnn
	os.system(cmd)
	cmd1 = "mv "+fnn+" "+fn
	os.system(cmd1)

def changeword2(file):
	fn = file[:-1]
	fnn = file[:-1]+'_n'
	cmd = "sed s/Dreambox/Vu+/g "+fn+" > "+fnn
	os.system(cmd)
	cmd1 = "mv "+fnn+" "+fn
	os.system(cmd1)

do_unpack_append(){
	modify_po()
}

do_configure_prepend_vuplus() {
	cp -av ${WORKDIR}/Makefile.am ${S}/easymedia/po/
}

do_install_append_vuplus() {
	install -m 0644 ${WORKDIR}/dreamboxweb.png ${D}/usr/lib/enigma2/python/Plugins/Extensions/WebInterface/web-data/img/
	install -m 0644 ${WORKDIR}/dreamboxwebtv.png ${D}/usr/lib/enigma2/python/Plugins/Extensions/WebInterface/web-data/tpl/default/streaminterface/img
	install -m 0644 ${WORKDIR}/favicon.ico ${D}/usr/lib/enigma2/python/Plugins/Extensions/WebInterface/web-data/img/
}

python populate_packages_prepend() {
        enigma2_plugindir = bb.data.expand('${libdir}/enigma2/python/Plugins', d)
        do_split_packages(d, enigma2_plugindir, '^(\w+/\w+)', 'enigma2-plugin-%s', '%s', recursive=True, match_path=True, prepend=True)
        do_split_packages(d, enigma2_plugindir, '^(\w+/\w+).*/.*\.la$', 'enigma2-plugin-%s-dev', '%s (development)', recursive=True, match_path=True, prepend=True)
        do_split_packages(d, enigma2_plugindir, '^(\w+/\w+).*/.*\.a$', 'enigma2-plugin-%s-staticdev', '%s (static development)', recursive=True, match_path=True, prepend=True)
        do_split_packages(d, enigma2_plugindir, '^(\w+/\w+).*/\.debug/', 'enigma2-plugin-%s-dbg', '%s (debug)', recursive=True, match_path=True, prepend=True)
        def parseControlFile(dir, d, package):
                import os
		#ac3lipsync is renamed since 20091121 to audiosync.. but rename in cvs is not possible without lost of revision history..
		#so the foldername is still ac3lipsync
		if package == 'audiosync':
			package = 'ac3lipsync'
                src = open(dir + "/" + package.split('-')[-1] + "/CONTROL/control").read()
                for line in src.splitlines():
                        name, value = line.strip().split(': ', 1)
                        if name == 'Description':
                                d.setVar('DESCRIPTION_' + package, value)
                        elif name == 'Depends':
                                d.setVar('RDEPENDS_' + package, ' '.join(value.split(', ')))
                        elif name == 'Replaces':
                                d.setVar('RREPLACES_' + package, ' '.join(value.split(', ')))
                        elif name == 'Conflicts':
                                d.setVar('RCONFLICTS_' + package, ' '.join(value.split(', ')))
        srcdir = d.getVar('S', True)
        for package in d.getVar('PACKAGES', True).split():
                if package.startswith('enigma2-plugin-') and not package.endswith('-dev') and not package.endswith('-dbg') and not package.endswith('-staticdev'):
                        parseControlFile(srcdir, d, package)
}
