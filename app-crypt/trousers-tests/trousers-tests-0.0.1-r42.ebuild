# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="2bb0f13ac760eab16e4e524f7083ce03dbf01d35"
CROS_WORKON_TREE="fe7385d685cc734b663eaf895fd226e6fa0fd126"
CROS_WORKON_PROJECT="chromiumos/third_party/trousers"

inherit cros-workon autotest

DESCRIPTION="Trousers TPM tests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86 arm amd64"
DEPEND="app-crypt/trousers
  !<chromeos-base/autotest-tests-0.0.1-r1521"
RDEPEND="${DEPEND}"

# Enable autotest by default.
IUSE="${IUSE} +autotest"

IUSE_TESTS="
	+tests_hardware_TPM
"

IUSE="${IUSE} ${IUSE_TESTS}"

CROS_WORKON_LOCALNAME=trousers

# path from root of repo
AUTOTEST_CLIENT_SITE_TESTS=autotest

src_configure() {
	cros-workon_src_configure
}

src_compile() {
	# for Makefile
	export TROUSERS_DIR=${WORKDIR}/${P}
	autotest_src_compile
}


