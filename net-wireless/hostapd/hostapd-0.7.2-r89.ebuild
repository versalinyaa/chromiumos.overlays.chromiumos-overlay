# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/hostapd/hostapd-0.7.1.ebuild,v 1.1 2010/01/24 20:49:34 gurligebis Exp $

EAPI="4"
CROS_WORKON_COMMIT="9fbd3f9ba84379ab56f3396017bc9811967e63ca"
CROS_WORKON_TREE="f6a485a46f781c4779c088000dfdebbd3580e189"
CROS_WORKON_PROJECT="chromiumos/third_party/hostap"
CROS_WORKON_LOCALNAME="wpa_supplicant"

inherit toolchain-funcs eutils cros-workon

DESCRIPTION="IEEE 802.11 wireless LAN Host AP daemon"
HOMEPAGE="http://hostap.epitest.fi"
#SRC_URI="http://hostap.epitest.fi/releases/${P}.tar.gz"

LICENSE="|| ( GPL-2 BSD )"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang ipv6 logwatch madwifi +ssl +wps
	weak_urandom_low_security spectrum_mgmt"
REQUIRED_USE="asan? ( clang )"

DEPEND="ssl? ( dev-libs/openssl )
	dev-libs/libnl:0
	madwifi? ( ||
		( >net-wireless/madwifi-ng-tools-0.9.3
		net-wireless/madwifi-old ) )"
RDEPEND="${DEPEND}"

MY_S="${WORKDIR}/${P}/hostapd"

src_prepare() {
	cd ${MY_S}
	sed -i -e "s:/etc/hostapd:/etc/hostapd/hostapd:g" \
		"${MY_S}/hostapd.conf"
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure
	local CONFIG="${MY_S}/.config"

	# toolchain setup
	echo "CC = $(tc-getCC)" > ${CONFIG}

	# EAP authentication methods
	echo "CONFIG_EAP=y" >> ${CONFIG}
	echo "CONFIG_EAP_MD5=y" >> ${CONFIG}

	if use ssl; then
		# SSL authentication methods
		echo "CONFIG_EAP_TLS=y" >> ${CONFIG}
		echo "CONFIG_EAP_TTLS=y" >> ${CONFIG}
		echo "CONFIG_EAP_MSCHAPV2=y" >> ${CONFIG}
		echo "CONFIG_EAP_PEAP=y" >> ${CONFIG}
	fi

	if use wps; then
		# Enable Wi-Fi Protected Setup
		echo "CONFIG_WPS=y" >> ${CONFIG}
		echo "CONFIG_WPS_UPNP=y" >> ${CONFIG}
		einfo "Enabling Wi-Fi Protected Setup support"
	fi

	echo "CONFIG_EAP_GTC=y" >> ${CONFIG}
	echo "CONFIG_EAP_SIM=y" >> ${CONFIG}
	echo "CONFIG_EAP_AKA=y" >> ${CONFIG}
	echo "CONFIG_EAP_PAX=y" >> ${CONFIG}
	echo "CONFIG_EAP_PSK=y" >> ${CONFIG}
	echo "CONFIG_EAP_SAKE=y" >> ${CONFIG}
	echo "CONFIG_EAP_GPSK=y" >> ${CONFIG}
	echo "CONFIG_EAP_GPSK_SHA256=y" >> ${CONFIG}
        echo "CONFIG_IEEE80211W=y" >> ${CONFIG}

	einfo "Enabling drivers: "

	if use madwifi; then
		# Add include path for madwifi-driver headers
		einfo "  Madwifi driver enabled"
		echo "CFLAGS += -I/usr/include/madwifi" >> ${CONFIG}
		echo "CONFIG_DRIVER_MADWIFI=y" >> ${CONFIG}
	else
		einfo "  Madwifi driver disabled"
	fi

	einfo "  nl80211 driver enabled"
	echo "CONFIG_DRIVER_NL80211=y" >> ${CONFIG}
	echo "CONFIG_DRIVER_WIRED=y" >> ${CONFIG}

	# misc
	echo "CONFIG_RADIUS_SERVER=y" >> ${CONFIG}
	echo "CONFIG_IEEE80211N=y" >> ${CONFIG}

	if use ipv6; then
		# IPv6 support
		echo "CONFIG_IPV6=y" >> ${CONFIG}
	fi

	echo "CONFIG_RSN_PREAUTH=y" >> ${CONFIG}
	echo "CONFIG_DEBUG_FILE=y" >> ${CONFIG}

	if use weak_urandom_low_security; then
		ewarn "hostapd is being configured to use a weak random"
		ewarn "number generator.  You should not use this in a"
		ewarn "production environment!"
		echo "CONFIG_WEAK_URANDOM_LOW_SECURITY=y" >> ${CONFIG}
	fi
	if use spectrum_mgmt; then
		echo "CONFIG_SPECTRUM_MANAGEMENT_CAPABILITY=y" >> ${CONFIG}
	fi

	default_src_configure
}

src_compile() {
	default_src_compile

	emake -C hostapd

	if use ssl; then
		cd ${MY_S}
		emake nt_password_hash
		emake hlr_auc_gw
	fi
}

src_install() {
	cd ${MY_S}
	dosbin hostapd
	dobin hostapd_cli

	use ssl && dobin nt_password_hash
	use ssl && dobin hlr_auc_gw

	doman hostapd.8 hostapd_cli.1

	dodoc ChangeLog README
	if use wps; then
		dodoc README-WPS
	fi

	docinto examples
	dodoc wired.conf

	if use logwatch; then
		insinto /etc/log.d/conf/services/
		doins logwatch/hostapd.conf

		exeinto /etc/log.d/scripts/services/
		doexe logwatch/hostapd
	fi
}

pkg_postinst() {
	einfo
	einfo "In order to use ${PN} you need to set up your wireless card"
	einfo "for master mode in /etc/conf.d/net and then start"
	einfo "/etc/init.d/hostapd."
	einfo
	einfo "Example configuration:"
	einfo
	einfo "config_wlan0=( \"192.168.1.1/24\" )"
	einfo "channel_wlan0=\"6\""
	einfo "essid_wlan0=\"test\""
	einfo "mode_wlan0=\"master\""
	einfo
	if use madwifi; then
		einfo "This package compiles against the headers installed by"
		einfo "madwifi-old, madwifi-ng or madwifi-ng-tools."
		einfo "You should remerge ${PN} after upgrading these packages."
		einfo
		einfo "Since you are using the madwifi-ng driver, you should disable or"
		einfo "comment out wme_enabled from hostapd.conf, since it will"
		einfo "cause problems otherwise (see bug #260377"
	fi
	#if [ -e "${KV_DIR}"/net/mac80211 ]; then
	#	einfo "This package now compiles against the headers installed by"
	#	einfo "the kernel source for the mac80211 driver. You should "
	#	einfo "re-emerge ${PN} after upgrading your kernel source."
	#fi

	if use wps; then
		einfo "You have enabled Wi-Fi Protected Setup support, please"
		einfo "read the README-WPS file in /usr/share/doc/${P}"
		einfo "for info on how to use WPS"
	fi
}
