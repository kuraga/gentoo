# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_FULLY_TESTED=( python3_{11..13} )
PYTHON_COMPAT=( "${PYTHON_FULLY_TESTED[@]}" python3_14 )
inherit distutils-r1 optfeature

DESCRIPTION="Python library for serializing any arbitrary object graph into JSON"
HOMEPAGE="
	https://github.com/jsonpickle/jsonpickle/
	https://pypi.org/project/jsonpickle/
"
SRC_URI="
	https://github.com/jsonpickle/jsonpickle/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm64 ~riscv x86 ~amd64-linux ~x86-linux"
IUSE="test-full"

BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
	test? (
		dev-python/feedparser[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/simplejson[${PYTHON_USEDEP}]
		dev-python/sqlalchemy[${PYTHON_USEDEP}]
		dev-python/ujson[${PYTHON_USEDEP}]
		test-full? (
			$(python_gen_cond_dep '
				dev-python/gmpy2[${PYTHON_USEDEP}]
				dev-python/pandas[${PYTHON_USEDEP}]
			' "${PYTHON_FULLY_TESTED[@]}")
		)
	)
"

distutils_enable_tests pytest

python_prepare_all() {
	distutils-r1_python_prepare_all

	export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}
}

python_test() {
	local EPYTEST_IGNORE=(
		# unpackaged bson dependency
		tests/bson_test.py
	)

	if ! use test-full || ! has_version "dev-python/gmpy2[${PYTHON_USEDEP}]"; then
		EPYTEST_IGNORE+=( jsonpickle/ext/gmpy.py )
	fi
	if ! use test-full || ! has_version "dev-python/pandas[${PYTHON_USEDEP}]"; then
		EPYTEST_IGNORE+=( jsonpickle/ext/pandas.py )
	fi

	epytest tests
}

pkg_postinst() {
	# Unpackaged optional backends: yajl, demjson
	optfeature "encoding numpy-based data" dev-python/numpy
	optfeature "encoding pandas objects" dev-python/pandas
	optfeature "fast JSON backend" dev-python/simplejson
}
