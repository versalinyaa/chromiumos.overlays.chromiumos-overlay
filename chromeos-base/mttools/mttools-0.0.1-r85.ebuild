# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="3347d5f0b49b44e335e90129e983997d69d04a49"
CROS_WORKON_TREE="6d8bf7b99a9a28938cd68bd2d54313c3ac1151b5"
CROS_WORKON_PROJECT="chromiumos/platform/mttools"

inherit cros-workon cros-constants cros-debug

DESCRIPTION="Chromium OS multitouch utilities"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="242728"

RDEPEND="chromeos-base/gestures
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	app-misc/utouch-evemu
	chromeos-base/libevdev"

DEPEND=${RDEPEND}

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_install() {
	# install to autotest deps directory for dependency
	emake DESTDIR="${D}${AUTOTEST_BASE}/client/deps/touchpad-tests/framework" install
}