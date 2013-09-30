# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="0bb175043fd06699f4b2d07cfe8b0db2cbbe625d"
CROS_WORKON_TREE="82687607aab83a4d2301d589034b238551967992"
CROS_WORKON_PROJECT="chromiumos/platform/mist"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon udev

DESCRIPTION="Chromium OS Modem Interface Switching Tool"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="-asan -clang platform2 test"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="180609"

RDEPEND="
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/libchromeos
	chromeos-base/metrics
	chromeos-base/platform2
	dev-libs/protobuf
	sys-fs/udev
	virtual/libusb:1
"

DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gmock )
	test? ( dev-cpp/gtest )
"

src_prepare() {
	use platform2 && return 0
	cros-workon_src_prepare
}

src_configure() {
	use platform2 && return 0
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	use platform2 && return 0
	cros-workon_src_compile
}

src_test() {
	use platform2 && return 0
	cros-workon_src_test
}

src_install() {
	use platform2 && return 0
	cros-workon_src_install

	dobin "${OUT}"/mist

	insinto /usr/share/mist
	doins default.conf

	udev_dorules 51-mist.rules
}