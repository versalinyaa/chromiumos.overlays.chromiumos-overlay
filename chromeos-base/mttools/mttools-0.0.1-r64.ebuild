# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="d872d689ae772840306989adb6c72f38405e46ff"
CROS_WORKON_TREE="ad4323fb55c1ef4d3d35916a7c3d6d754f40d553"
CROS_WORKON_PROJECT="chromiumos/platform/mttools"

inherit cros-workon

DESCRIPTION="Chromium OS multitouch utilities"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

RDEPEND="chromeos-base/gestures
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
	emake DESTDIR="${D}/usr/local/autotest/client/deps/touchpad-tests/framework" install
}