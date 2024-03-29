# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="414771453db184690c8dcb6ffe2ce2e0688f972f"
CROS_WORKON_TREE="d3ae62019a520afdf54425661122f2721b3bd40d"
CROS_WORKON_PROJECT="chromiumos/platform/gestures"
CROS_WORKON_USE_VCSID=1

inherit toolchain-funcs multilib cros-debug cros-workon

DESCRIPTION="Gesture recognizer library"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang +X"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="271506"

RDEPEND="chromeos-base/libevdev
	>=dev-cpp/gflags-2.0
	dev-libs/jsoncpp
	sys-fs/udev"
DEPEND="dev-cpp/gtest
	X? ( x11-libs/libXi )
	${RDEPEND}"

src_configure() {
	clang-setup-env
	cros-workon_src_configure
	export USE_X11=$(usex X 1 0)
}

src_compile() {
	tc-export CXX
	cros-debug-add-NDEBUG
	export BASE_VER=${LIBCHROME_VERS}

	emake clean  # TODO(adlr): remove when a better solution exists
	emake
}

src_test() {
	emake test

	if ! use x86 && ! use amd64 ; then
		einfo "Skipping tests on non-x86 platform..."
	else
		./test || die
	fi
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="/usr/$(get_libdir)" install
}
