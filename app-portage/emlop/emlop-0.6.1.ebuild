# Copyright 2023-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Auto-Generated by cargo-ebuild 0.5.4

EAPI=8

CRATES="
	aho-corasick-1.0.2
	anstyle-1.0.1
	anyhow-1.0.71
	assert_cmd-2.0.11
	atoi-2.0.0
	atty-0.2.14
	autocfg-1.1.0
	bitflags-1.3.2
	bstr-1.5.0
	cfg-if-1.0.0
	clap-3.2.25
	clap_complete-3.2.5
	clap_derive-3.2.25
	clap_lex-0.2.4
	crossbeam-channel-0.5.8
	crossbeam-utils-0.8.16
	difflib-0.4.0
	doc-comment-0.3.3
	either-1.8.1
	emlop-0.6.1
	env_logger-0.10.0
	hashbrown-0.12.3
	heck-0.4.1
	hermit-abi-0.1.19
	indexmap-1.9.3
	itertools-0.10.5
	itoa-1.0.6
	libc-0.2.146
	log-0.4.19
	memchr-2.5.0
	num-traits-0.2.15
	num_threads-0.1.6
	once_cell-1.18.0
	os_str_bytes-6.5.1
	predicates-3.0.3
	predicates-core-1.0.6
	predicates-tree-1.0.9
	proc-macro-error-1.0.4
	proc-macro-error-attr-1.0.4
	proc-macro2-1.0.60
	quote-1.0.28
	regex-1.8.4
	regex-automata-0.1.10
	regex-syntax-0.7.2
	rev_lines-0.3.0
	ryu-1.0.13
	serde-1.0.164
	serde_derive-1.0.164
	serde_json-1.0.97
	strsim-0.10.0
	syn-1.0.109
	syn-2.0.18
	termcolor-1.2.0
	termtree-0.4.1
	textwrap-0.16.0
	thiserror-1.0.40
	thiserror-impl-1.0.40
	time-0.3.22
	time-core-0.1.1
	time-macros-0.2.9
	unicode-ident-1.0.9
	version_check-0.9.4
	wait-timeout-0.2.0
	winapi-0.3.9
	winapi-i686-pc-windows-gnu-0.4.0
	winapi-util-0.1.5
	winapi-x86_64-pc-windows-gnu-0.4.0
"

inherit cargo shell-completion

DESCRIPTION="A fast, accurate, ergonomic emerge.log parser"
HOMEPAGE="https://github.com/vincentdephily/emlop"
SRC_URI="$(cargo_crate_uris)"

LICENSE="GPL-3"
# Dependent crate licenses
LICENSE+="
	   MIT Unicode-DFS-2016
	   || ( Apache-2.0 Boost-1.0 )
"

SLOT="0"
KEYWORDS="amd64"

BDEPEND=">=virtual/rust-1.65.0"

# rust does not use *FLAGS from make.conf, silence portage warning
QA_FLAGS_IGNORED="usr/bin/${PN}"

src_install() {
	cargo_src_install
	dodoc README.md CHANGELOG.md
	# bash
	"$(cargo_target_dir)"/emlop complete bash > emlop || die
	dobashcomp emlop
	# zsh
	"$(cargo_target_dir)"/emlop complete zsh > _emlop || die
	dozshcomp _emlop
	# fish
	"$(cargo_target_dir)"/emlop complete fish > emlop.fish || die
	dofishcomp emlop.fish
}
