# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="68ac5a1ac7d09592cf40edd60b07faf8479f7145"
CROS_WORKON_TREE="8cea27d71d3917603ba48d128260c6cb0e368094"
CROS_WORKON_PROJECT="chromiumos/platform/crosh"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Chrome OS command-line shell"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="app-admin/sudo
	chromeos-base/vboot_reference
	chromeos-base/workarounds
	net-misc/iputils
	net-misc/openssh
	net-wireless/iw
	sys-apps/net-tools
"
DEPEND=""

src_compile() {
	# File order is important here.
	sed \
		-e '/^#/d' \
		-e '/^$/d' \
		inputrc.safe inputrc.extra \
		> "${WORKDIR}"/inputrc.crosh || die
}

src_install() {
	dobin crosh crosh-{dev,usb}
	dobin network_diagnostics
	insinto /usr/share/misc
	doins "${WORKDIR}"/inputrc.crosh
}