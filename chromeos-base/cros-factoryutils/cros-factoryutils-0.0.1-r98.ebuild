# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# TODO(jsalz): Remove this ebuild; it's no longer used.

EAPI="4"
CROS_WORKON_COMMIT="48cc327c314dcf0778a10fec75682f3f82b1dfdf"
CROS_WORKON_TREE="a31961c444111c310645ba5e1d1049a824958691"
CROS_WORKON_PROJECT="chromiumos/platform/factory-utils"

inherit cros-workon

DESCRIPTION="Factory development utilities for ChromiumOS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="cros_factory_bundle"

CROS_WORKON_LOCALNAME="factory-utils"
RDEPEND="dev-util/dialog"

# chromeos-installer for solving "lib/chromeos-common.sh" symlink.
# vboot_reference for binary programs (ex, cgpt).
DEPEND="chromeos-base/chromeos-installer[cros_host]
        chromeos-base/vboot_reference"

src_compile() {
    true
}

src_install() {
    true
}