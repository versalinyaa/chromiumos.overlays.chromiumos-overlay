# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="17b3a32bbfab60e7a999ba687d7c6eaa554e1fc8"
CROS_WORKON_TREE="2c3a4de551bd6e1c03847adb24ced29b6b98e44e"
CROS_WORKON_PROJECT="chromiumos/platform/init"
CROS_WORKON_LOCALNAME="init"

inherit cros-workon

DESCRIPTION="Additional upstart jobs that will be installed on test images"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"

# TODO(victoryang): Remove factorytest-init package entirely after Feb 2014.
#                   crosbug.com/p/24798.
DEPEND=">=chromeos-base/factorytest-init-0.0.1-r32"

src_install() {
	insinto /etc/init
	doins test-init/*.conf
}
