# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="11af0628754be91d2db5bbc3619dcd717559a85c"
CROS_WORKON_TREE="8be23a0c14246835e8ac2ba9076fa4d6fd38dac3"
CROS_WORKON_PROJECT="chromiumos/platform/minijail"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Chrome OS helper binary for restricting privs of services."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="sys-libs/libcap"
DEPEND="test? ( dev-cpp/gtest )
	test? ( dev-cpp/gmock )
	${RDEPEND}"

CROS_WORKON_LOCALNAME=$(basename ${CROS_WORKON_PROJECT})

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	# Only build the tools
	emake LIBDIR=$(get_libdir) || die
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	# TODO(wad) switch to common.mk to get qemu and valgrind coverage
	emake tests || die "unit tests compile failed."

	if use x86 || use amd64 ; then
		./libminijail_unittest  || \
		    die "libminijail unit tests failed!"
		./syscall_filter_unittest || \
		    die "syscall filter unit tests failed!"
	fi
}

src_install() {
	into /
	dosbin minijail0 || die
	dolib.so libminijail.so || die
	dolib.so libminijailpreload.so || die
	insinto /usr/include/chromeos
	doins libminijail.h || die
}