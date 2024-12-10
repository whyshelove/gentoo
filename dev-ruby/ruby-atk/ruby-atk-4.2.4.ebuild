# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
USE_RUBY="ruby31 ruby32 ruby33"

inherit ruby-ng-gnome2

DESCRIPTION="Ruby Atk bindings"
KEYWORDS="~amd64 ~ppc ~riscv ~x86"
RDEPEND="dev-libs/atk[introspection]"

ruby_add_rdepend "
	~dev-ruby/ruby-glib2-${PV}
	~dev-ruby/ruby-gobject-introspection-${PV}"
