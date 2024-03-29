# chromeos-factory-mini is a subset of the factory software that can
# be used to run utilities like gooftool, hwid, and regcode, which may
# be useful in the CrOS test environment.  For instance, this would
# allow "gooftool probe" to be used to probe hardware components in
# Moblab.
#
# We don't want to install the entire chromeos-factory package in the
# test image, since it is quite large, so this package comprises a
# small ".par" file (/usr/local/factory-mini/factory-mini.par)
# containing the necessary subset of factory Python code, and symlinks
# from /usr/local/bin to that file.

EAPI=5
CROS_WORKON_COMMIT="e04078a7383169107794d639f426152801761786"
CROS_WORKON_TREE="14d035681e3fa852e29ba5e6f3435de11fe67bd2"
CROS_WORKON_PROJECT="chromiumos/platform/factory"
CROS_WORKON_LOCALNAME="factory"
CROS_WORKON_DESTDIR="${S}"

inherit cros-workon

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
DESCRIPTION="Subset of factory software to be installed in test images"

DEPEND="dev-lang/python"

src_compile() {
	emake par MAKE_PAR_ARGS=--mini PAR_NAME=factory-mini.par
}

src_install() {
	exeinto /usr/local/factory-mini
	doexe build/par/factory-mini.par

	# Sanity check: make sure we can run gooftool --help with only
	# the -mini.par file.
	build/par/factory-mini.par gooftool --help |
		grep -q "^usage: gooftool" || die

	# Install only symlinks for binaries usable with factory-mini.par.
	"${S}/bin/install_symlinks" \
		--mode mini --target ../factory-mini/factory-mini.par \
		"${D}"/usr/local/bin || die
}
