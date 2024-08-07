# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517="setuptools"
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1

DESCRIPTION="A python implementation for Noise Protocol Framework"
HOMEPAGE="
	https://github.com/tgalal/dissononce/
	https://pypi.org/project/dissononce/
"
SRC_URI="
	https://github.com/tgalal/dissononce/archive/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="examples test"

RDEPEND="
	dev-python/cryptography[${PYTHON_USEDEP}]
	dev-python/transitions[${PYTHON_USEDEP}]
"
BDEPEND="
	${RDEPEND}
"

PATCHES=(
	"${FILESDIR}/${P}-fix-test-requirements.patch"
)

distutils_enable_tests pytest

src_install() {
	distutils-r1_src_install

	use examples && dodoc examples/patterns/*.py
}
