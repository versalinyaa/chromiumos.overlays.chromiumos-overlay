# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
CROS_WORKON_COMMIT="a9c64b3458994f81c3350cc733adb5fe9ba220f5"
CROS_WORKON_TREE="43f62a575c6dba861e7b0e9b14fd550d80487303"
CROS_WORKON_PROJECT="chromiumos/platform/userfeedback"

inherit cros-workon

DESCRIPTION="Log scripts used by userfeedback to report cros system information"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="X"

RDEPEND="chromeos-base/chromeos-init
	chromeos-base/modem-utilities
	chromeos-base/vboot_reference
	media-libs/fontconfig
	media-sound/alsa-utils
	sys-apps/hdparm
	sys-apps/mmc-utils
	sys-apps/mosys
	sys-apps/net-tools
	sys-apps/pciutils
	sys-apps/smartmontools
	sys-apps/usbutils
	X? ( x11-apps/setxkbmap )"

DEPEND=""

src_test() {
        test/storage_info_unit_test || die "Unit test failed"
}

src_install() {
	exeinto /usr/share/userfeedback/scripts
	doexe scripts/* || die "Could not copy scripts"

	insinto /usr/share/userfeedback/etc
	doins etc/* || die "Could not copy etc"

        insinto /etc/init
        doins init/* || die "Could not copy init"
}