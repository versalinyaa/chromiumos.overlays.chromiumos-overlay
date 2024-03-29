# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libdrm/libdrm-2.4.50.ebuild,v 1.1 2013/12/04 12:08:51 chithanh Exp $

EAPI=4
inherit xorg-2

EGIT_REPO_URI="git://anongit.freedesktop.org/git/mesa/drm"

DESCRIPTION="X.Org libdrm library"
HOMEPAGE="http://dri.freedesktop.org/"
if [[ ${PV} = 9999* ]]; then
	SRC_URI=""
else
	SRC_URI="http://dri.freedesktop.org/${PN}/${P}.tar.bz2"
fi

# This package uses the MIT license inherited from Xorg but fails to provide
# any license file in its source, so we add X as a license, which lists all
# the Xorg copyright holders and allows license generation to pick them up.
LICENSE="|| ( MIT X )"
KEYWORDS="*"
VIDEO_CARDS="exynos freedreno intel nouveau omap radeon vmware rockchip"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS} libkms manpages drm_atomic"
REQUIRED_USE="video_cards_exynos? ( libkms )
	video_cards_rockchip? ( libkms )"
RESTRICT="test" # see bug #236845

RDEPEND="dev-libs/libpthread-stubs
	video_cards_intel? ( >=x11-libs/libpciaccess-0.10 )"
DEPEND="${RDEPEND}"

XORG_EAUTORECONF=yes
PATCHES=(
	"${FILESDIR}"/drm_rockchip_0001_add_support_for_rockchip.patch
)

src_prepare() {
	if [[ ${PV} = 9999* ]]; then
		# tests are restricted, no point in building them
		sed -ie 's/tests //' "${S}"/Makefile.am
	fi
	xorg-2_src_prepare
	if use drm_atomic; then
		epatch ${FILESDIR}/drm_atomic-*.patch
	fi
}

src_configure() {
	XORG_CONFIGURE_OPTIONS=(
		--enable-udev
		$(use_enable video_cards_exynos exynos-experimental-api)
		$(use_enable video_cards_freedreno freedreno-experimental-api)
		$(use_enable video_cards_intel intel)
		$(use_enable video_cards_nouveau nouveau)
		$(use_enable video_cards_omap omap-experimental-api)
		$(use_enable video_cards_radeon radeon)
		$(use_enable video_cards_vmware vmwgfx)
		$(use_enable video_cards_rockchip rockchip-experimental-api)
		$(use_enable libkms)
		$(use_enable manpages)
	)
	xorg-2_src_configure
}
