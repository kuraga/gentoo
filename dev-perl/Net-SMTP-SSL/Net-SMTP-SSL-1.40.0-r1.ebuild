# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=RJBS
DIST_VERSION=1.04
inherit perl-module

DESCRIPTION="(Deprecated) SSL support for Net::SMTP"

SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux"

RDEPEND="
	virtual/perl-libnet
	dev-perl/IO-Socket-SSL
"
BDEPEND="${RDEPEND}
	virtual/perl-ExtUtils-MakeMaker
	test? ( >=virtual/perl-Test-Simple-0.470.0 )
"

pkg_postinst() {
	elog "This package is deprecated by upstream as equivalent support for SSL and"
	elog "STARTTLS is available with Net::SMTP 2.35, found in:"
	elog "  >=virtual/perl-libnet-1.28 ( >=dev-lang/perl-5.20.0 )"
	elog "Subsequently, this package is only available for compatibility reasons, and"
	elog "should be avoided in new code."
}
