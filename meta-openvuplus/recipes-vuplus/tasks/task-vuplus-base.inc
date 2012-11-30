SUMMARY = "Vuplus: Base Task for Vuplus."
SECTION = "vuplus/base"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"
INC_PR = "r0"

inherit task

VUPLUS_BASE_ESSENTIAL = "\
  autofs \
  base-files-doc \
  vuplus-compat \
  dreambox-keymaps \
  e2fsprogs-e2fsck \
  e2fsprogs-mke2fs \
  fakelocale \
  opkg \
  timezones-alternative \
  tuxbox-common \
  util-linux-sfdisk \
  vsftpd \
  mtd-utils \
  hdparm \
  usbtunerhelper \
  ${VUPLUS_FIRMWARE_DVB} \
"

VUPLUS_FIRMWARE_DVB = " \
  firmware-dvb-af9005 \
  firmware-dvb-fe-af9013 \
  firmware-dvb-usb-af9015 \
  firmware-dvb-usb-af9035 \
  firmware-dvb-usb-avertv-a800 \
  firmware-dvb-usb-dib0700 \
  firmware-dvb-usb-dibusb \
  firmware-dvb-usb-digitv \
  firmware-dvb-usb-nova-t-usb2 \
  firmware-dvb-usb-sms1xxx-nova-dvbt \
  firmware-dvb-usb-sms1xxx-hcw-dvbt \
  firmware-dvb-usb-ttusb-budget \
  firmware-dvb-usb-umt-010 \
  firmware-dvb-usb-xc5000 \
  firmware-dvb-usb-wt220u-zl0353 \
  firmware-drxd-a2 \
"

# chang : use xinetd instead of netkit-base.
# chang : mkfs-ubifs and mkfs-jffs2 are included in mtd-utils.

VUPLUS_BASE_RECOMMENDS = "\
  dropbear \
  vuplus-vucamd \
  sambaserver \
  openvpn \
  zeroconf \
"

#VUPLUS_BASE_RECOMMENDS_append_vuuno = " vuplus-fpga-update"
#VUPLUS_BASE_RECOMMENDS_append_vuultimo = " vuplus-fpga-update"

VUPLUS_BASE_OPTIONAL_RECOMMENDS = "\
  gdbserver \
  hddtemp \
  joe \
  mc \
  ncdu \
  ppp \
  smartmontools \
  avahi-daemon \
"

RDEPENDS_${PN} += "\
        ${VUPLUS_BASE_ESSENTIAL} \
"

RRECOMMENDS_${PN} += "\
        ${VUPLUS_BASE_RECOMMENDS} \
        ${VUPLUS_BASE_OPTIONAL_RECOMMENDS} \
"