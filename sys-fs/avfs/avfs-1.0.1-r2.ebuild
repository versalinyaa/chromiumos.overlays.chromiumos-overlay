# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/avfs/avfs-1.0.1.ebuild,v 1.1 2012/06/13 07:58:44 radhermit Exp $

EAPI=4
inherit eutils

DESCRIPTION="AVFS is a virtual filesystem that allows browsing of compressed files."
HOMEPAGE="http://sourceforge.net/projects/avf"
SRC_URI="mirror://sourceforge/avf/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="static-libs +lzma"

RDEPEND=">=sys-fs/fuse-2.4
	sys-libs/zlib
	app-arch/bzip2
	lzma? ( app-arch/xz-utils )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	# Work around a malformed zip file that doesn't set any file type on
	# a zip entry (crbug.com/173383).
	epatch "${FILESDIR}"/${P}-zip-attr-fix.patch

	# Work around a zip file with extra bytes at the beginning of the file
	# (crbug.com/336690).
	epatch "${FILESDIR}"/${P}-zip-handle-extra-bytes.patch
}

src_configure() {
	econf \
		--enable-fuse \
		--enable-library \
		--enable-shared \
		--with-system-zlib \
		--with-system-bzlib \
		$(use_enable static-libs static) \
		$(use_with lzma xz)
}

src_install() {
	default

	# remove cruft
	rm "${D}"/usr/bin/{davpass,ftppass} || die

	# install docs
	dodoc doc/{api-overview,background,FORMAT,INSTALL.*,README.avfs-fuse}
	dosym /usr/lib/avfs/extfs/README /usr/share/doc/${PF}/README.extfs

	docinto scripts
	dodoc scripts/{avfscoda*,*pass}

	prune_libtool_files
}

pkg_postinst() {
	einfo "This version of AVFS includes FUSE support. It is user-based."
	einfo "To execute:"
	einfo "1) as user, mkdir ~/.avfs"
	einfo "2) make sure fuse is either compiled into the kernel OR"
	einfo "   modprobe fuse or add to startup."
	einfo "3) run mountavfs"
	einfo "To unload daemon, type umountavfs"
	einfo
	einfo "READ the documentation! Enjoy :)"
}
