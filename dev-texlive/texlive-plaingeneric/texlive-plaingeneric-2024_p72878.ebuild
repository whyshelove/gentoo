# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TEXLIVE_MODULE_CONTENTS="
	collection-plaingeneric.r72878
	abbr.r15878
	abstyles.r15878
	advice.r70688
	apnum.r47510
	autoaligne.r66655
	barr.r38479
	bitelist.r25779
	borceux.r21047
	c-pascal.r18337
	calcfrac.r68684
	catcodes.r38859
	chronosys.r26700
	collargs.r70689
	colorsep.r13293
	compare.r54265
	crossrefenum.r70954
	cweb-old.r49271
	dinat.r15878
	dirtree.r42428
	docbytex.r34294
	dowith.r38860
	eijkhout.r15878
	encxvlna.r34087
	epigram.r20513
	epsf.r21461
	epsf-dvipdfmx.r35575
	etoolbox-generic.r68513
	expex-acro.r68046
	expkv-bundle.r65623
	fenixpar.r24730
	figflow.r21462
	fixpdfmag.r15878
	fltpoint.r56594
	fntproof.r20638
	font-change.r40403
	fontch.r17859
	fontname.r64477
	gates.r29803
	getoptk.r23567
	gfnotation.r37156
	gobble.r64967
	graphics-pln.r71575
	gtl.r69297
	hlist.r44983
	hyplain.r15878
	ifis-macros.r71220
	inputnormalization.r59850
	insbox.r34299
	js-misc.r16211
	kastrup.r15878
	lambda-lists.r31402
	langcode.r27764
	lecturer.r23916
	letterspacing.r54266
	librarian.r19880
	listofitems.r70579
	localloc.r56496
	mathdots.r34301
	metatex.r15878
	midnight.r15878
	mkpattern.r15878
	mlawriter.r67558
	modulus.r47599
	multido.r18302
	namedef.r55881
	navigator.r41413
	newsletr.r15878
	nth.r54252
	ofs.r16991
	olsak-misc.r65631
	outerhbox.r54254
	path.r22045
	pdf-trans.r32809
	pdfmsym.r66618
	pitex.r24731
	placeins-plain.r15878
	plainpkg.r27765
	plipsum.r30353
	plnfss.r15878
	plstmary.r31088
	poormanlog.r63400
	present.r50048
	pwebmac.r72015
	random.r54723
	randomlist.r45281
	resumemac.r15878
	ruler.r54251
	schemata.r58020
	shade.r22212
	simplekv.r68439
	soul.r67365
	swrule.r54267
	systeme.r66655
	tabto-generic.r15878
	termmenu.r37700
	tex-ps.r15878
	texapi.r54080
	texdate.r49362
	texdimens.r61070
	texinfo.r69809
	timetable.r15878
	tracklang.r65263
	treetex.r28176
	trigonometry.r43006
	tuple.r72878
	ulem.r53365
	upca.r22511
	varisize.r15878
	xintsession.r60926
	xlop.r56910
	yax.r54080
	zztex.r55862
"
TEXLIVE_MODULE_DOC_CONTENTS="
	abbr.doc.r15878
	abstyles.doc.r15878
	advice.doc.r70688
	apnum.doc.r47510
	autoaligne.doc.r66655
	barr.doc.r38479
	bitelist.doc.r25779
	borceux.doc.r21047
	c-pascal.doc.r18337
	calcfrac.doc.r68684
	catcodes.doc.r38859
	chronosys.doc.r26700
	collargs.doc.r70689
	crossrefenum.doc.r70954
	dinat.doc.r15878
	dirtree.doc.r42428
	docbytex.doc.r34294
	dowith.doc.r38860
	encxvlna.doc.r34087
	epsf.doc.r21461
	epsf-dvipdfmx.doc.r35575
	etoolbox-generic.doc.r68513
	expex-acro.doc.r68046
	expkv-bundle.doc.r65623
	fenixpar.doc.r24730
	figflow.doc.r21462
	fltpoint.doc.r56594
	fntproof.doc.r20638
	font-change.doc.r40403
	fontch.doc.r17859
	fontname.doc.r64477
	gates.doc.r29803
	getoptk.doc.r23567
	gfnotation.doc.r37156
	gobble.doc.r64967
	graphics-pln.doc.r71575
	gtl.doc.r69297
	hlist.doc.r44983
	hyplain.doc.r15878
	ifis-macros.doc.r71220
	inputnormalization.doc.r59850
	insbox.doc.r34299
	js-misc.doc.r16211
	kastrup.doc.r15878
	lambda-lists.doc.r31402
	langcode.doc.r27764
	lecturer.doc.r23916
	librarian.doc.r19880
	listofitems.doc.r70579
	localloc.doc.r56496
	mathdots.doc.r34301
	metatex.doc.r15878
	midnight.doc.r15878
	mkpattern.doc.r15878
	mlawriter.doc.r67558
	modulus.doc.r47599
	multido.doc.r18302
	namedef.doc.r55881
	navigator.doc.r41413
	newsletr.doc.r15878
	ofs.doc.r16991
	olsak-misc.doc.r65631
	path.doc.r22045
	pdf-trans.doc.r32809
	pdfmsym.doc.r66618
	pitex.doc.r24731
	plainpkg.doc.r27765
	plipsum.doc.r30353
	plnfss.doc.r15878
	plstmary.doc.r31088
	poormanlog.doc.r63400
	present.doc.r50048
	pwebmac.doc.r72015
	random.doc.r54723
	randomlist.doc.r45281
	resumemac.doc.r15878
	schemata.doc.r58020
	shade.doc.r22212
	simplekv.doc.r68439
	soul.doc.r67365
	systeme.doc.r66655
	termmenu.doc.r37700
	tex-ps.doc.r15878
	texapi.doc.r54080
	texdate.doc.r49362
	texdimens.doc.r61070
	tracklang.doc.r65263
	transparent-io.doc.r64113
	treetex.doc.r28176
	trigonometry.doc.r43006
	tuple.doc.r72878
	ulem.doc.r53365
	upca.doc.r22511
	varisize.doc.r15878
	xii.doc.r45804
	xii-lat.doc.r45805
	xintsession.doc.r60926
	xlop.doc.r56910
	yax.doc.r54080
	zztex.doc.r55862
"
TEXLIVE_MODULE_SRC_CONTENTS="
	advice.source.r70688
	bitelist.source.r25779
	catcodes.source.r38859
	collargs.source.r70689
	dirtree.source.r42428
	dowith.source.r38860
	expex-acro.source.r68046
	expkv-bundle.source.r65623
	fltpoint.source.r56594
	gobble.source.r64967
	gtl.source.r69297
	inputnormalization.source.r59850
	kastrup.source.r15878
	langcode.source.r27764
	localloc.source.r56496
	mathdots.source.r34301
	modulus.source.r47599
	multido.source.r18302
	namedef.source.r55881
	plainpkg.source.r27765
	randomlist.source.r45281
	schemata.source.r58020
	soul.source.r67365
	termmenu.source.r37700
	texdate.source.r49362
	tracklang.source.r65263
"

inherit texlive-module

DESCRIPTION="TeXLive Plain (La)TeX packages"

LICENSE="CC0-1.0 FDL-1.1+ GPL-1+ GPL-2 GPL-3 GPL-3+ LPPL-1.0 LPPL-1.3 LPPL-1.3c MIT TeX TeX-other-free public-domain"
SLOT="0"
KEYWORDS="amd64"
COMMON_DEPEND="
	>=dev-texlive/texlive-basic-2024
"
RDEPEND="
	${COMMON_DEPEND}
"
DEPEND="
	${COMMON_DEPEND}
"
