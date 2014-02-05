# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="b88028ab64c435d23f18729925889a61bd17b9c2"
CROS_WORKON_TREE="97b31fa216314270adaf2cec4270b0b97eb31227"
CROS_WORKON_PROJECT="chromiumos/platform/bootstat"
inherit cros-workon

DESCRIPTION="Chrome OS Boot Time Statistics Utilities"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=""

DEPEND="dev-cpp/gtest"

src_configure() {
	cros-workon_src_configure
        tc-export CC CXX AR PKG_CONFIG
}

src_compile() {
	emake
}

src_test() {
	emake tests
	if ! use x86 && ! use amd64 ; then
		echo Skipping unit tests on non-x86 platform
	else
		for test in ./*_test; do
			"${test}" ${GTEST_ARGS} || die "${test} failed"
		done
	fi
}

src_install() {
	into /
	dosbin bootstat
	dosbin bootstat_archive
	dosbin bootstat_get_last
	dobin bootstat_summary

	into /usr
	dolib.a libbootstat.a

	insinto /usr/include/metrics
	doins bootstat.h
}