# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="b52419242b42625d621d47232397578cd8003d65"
CROS_WORKON_TREE="d828591c7b2bf5221c61a8b17aa6d935f2746a32"
CROS_WORKON_LOCALNAME="../platform/chromiumos-wide-profiling"
CROS_WORKON_PROJECT="chromiumos/platform/chromiumos-wide-profiling"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Program used to collect performance data on ChromeOS machines"
HOMEPAGE=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

LIBCHROME_VERS="180609"

COMMON_DEPEND="chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	dev-libs/openssl
	dev-libs/protobuf"
RDEPEND="${COMMON_DEPEND}
	virtual/perf"
DEPEND="${COMMON_DEPEND}
	test? ( dev-cpp/gtest )"

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_test() {
	cros-workon_src_test
}

src_install() {
	dobin quipper
}