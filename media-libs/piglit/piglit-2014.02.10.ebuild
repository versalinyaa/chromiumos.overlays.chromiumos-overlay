# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit cmake-utils

DESCRIPTION="A collection of automated tests for OpenGL implementations"
HOMEPAGE="http://people.freedesktop.org/~nh/piglit/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.bz2"

LICENSE="BSD GPL-2+ GPL-3 LGPL-2+ MIT"
SLOT="0"
KEYWORDS="*"
IUSE="dma_buf gbm opencl opengl opengles waffle"

# USE flags:
#	dma_buf  - build dma_buf tests (intel only)
#	gbm      - let piglit use mesa's gbm
#	opencl   - build OpenCL tests
#	opengl   - build OpenGL, GLX and DMA_BUF tests using GLUT by default
#	opengles - build OpenGL ES1 ES2 and ES3 tests always using waffle
#	waffle   - use waffle.  if not set, glut is used

REQUIRED_USE="
	opengles? ( waffle )
	"

RDEPEND="
	dev-python/mako
	dev-python/numpy
	>=dev-lang/python-2.7
	waffle? ( >=media-libs/waffle-1.2.2 )
	!waffle? ( virtual/glut )
	opencl? ( virtual/opencl )
	opengl? ( virtual/opengl )
	opengles? ( virtual/opengles )
	dma_buf? ( x11-libs/libdrm )
	"
DEPEND="${RDEPEND}
	opengl? ( x11-proto/glproto )
	"

PATCHES=(
	"${FILESDIR}/0001-glx_oml_sync_control-report-FAIL-if-glXGetMscRateOML.patch"
	"${FILESDIR}/0002-texturing-s3rc-errors-double-check-GL_TEXTURE-parame.patch"
	# Chrome OS graphics_Piglit have some additional checks
	"${FILESDIR}/monitor_tests_for_GPU_hang_and_SW_rasterization.patch"
	)

src_configure() {
	mycmakeargs=(
		$(cmake-utils_use opencl PIGLIT_BUILD_CL_TESTS)
		$(cmake-utils_use opengl PIGLIT_BUILD_GL_TESTS)
		$(cmake-utils_use opengles PIGLIT_BUILD_GLES1_TESTS)
		$(cmake-utils_use opengles PIGLIT_BUILD_GLES2_TESTS)
		$(cmake-utils_use opengles PIGLIT_BUILD_GLES3_TESTS)
		$(cmake-utils_use opengl PIGLIT_BUILD_GLX_TESTS)
		$(cmake-utils_use dma_buf PIGLIT_BUILD_DMA_BUF_TESTS)

		$(cmake-utils_use waffle PIGLIT_USE_WAFFLE)

		$(cmake-utils_use gbm PIGLIT_HAS_GBM)

		-DCMAKE_FIND_ROOT_PATH=${ROOT}
		-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER
		-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY
		-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY
		-DCMAKE_INSTALL_PREFIX=/usr/local/piglit

		# Set RPATH so piglit binaries can find piglit libs
		-DCMAKE_BUILD_WITH_INSTALL_RPATH=TRUE
		-DCMAKE_INSTALL_RPATH='$ORIGIN/../lib'
		-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=lib
	)

	# piglit CMakeLists.txt requires that CMAKE_C_COMPILER_ID be set.
	# This is not done by cmake-utils.eclass
	tc-export CC

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	# Chrome OS graphics_Piglit autotest tests, derived from tests/gpu.py
	insinto "/usr/local/piglit/tests"
	doins "${FILESDIR}/cros-driver.py"
}