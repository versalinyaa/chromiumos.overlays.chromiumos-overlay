# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="650f2303cf82693f41f4ee774ca2edce33a62c2a"
CROS_WORKON_TREE="bf4dc03d70aab48adce58d85ba98773e5850531d"
CROS_WORKON_PROJECT="chromiumos/platform/crosutils"
CROS_WORKON_LOCALNAME="../scripts/"

inherit cros-workon

DESCRIPTION="Chromium OS build utilities"
HOMEPAGE="http://www.chromium.org/chromium-os"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

src_configure() {
	find . -type l -exec rm {} \; &&
	rm -fr WATCHLISTS inherit-review-settings-ok lib/shflags ||
		die "Couldn't clean directory."
}

src_install() {
	# Install package files
	exeinto /usr/lib/crosutils
	doexe * || die "Could not install shared files."

	# Install libraries
	insinto /usr/lib/crosutils/lib
	doins lib/* || die "Could not install library files"
}