# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="e389a1e85a5c1c6ae417fa91dbde27f8710bc0bd"
CROS_WORKON_TREE="faa4fa1fcf8f1fd447985ce05da84a5d169c56f9"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel/3.14"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Linux Kernel 3.14"
KEYWORDS="*"

DEPEND="!sys-kernel/chromeos-kernel-3_10
	!sys-kernel/chromeos-kernel-baytrail
	!sys-kernel/chromeos-kernel-next
	!sys-kernel/chromeos-kernel"
RDEPEND="${DEPEND}"