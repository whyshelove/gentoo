# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TEXLIVE_MODULE_CONTENTS="
	collection-fontsextra.r72727
	aboensis.r62977
	academicons.r62622
	accanthis.r64844
	adforn.r72484
	adfsymbols.r72458
	aesupp.r58253
	alegreya.r64384
	alfaslabone.r57452
	algolrevived.r71368
	allrunes.r42221
	almendra.r64539
	almfixed.r35065
	andika.r64540
	anonymouspro.r51631
	antiqua.r24266
	antt.r18651
	archaic.r38005
	archivo.r57283
	arev.r15878
	arimo.r68950
	arsenal.r68191
	arvo.r57213
	asana-math.r59629
	asapsym.r40201
	ascii-font.r29989
	aspectratio.r25243
	astro.r15878
	atkinson.r71048
	augie.r61719
	auncial-new.r62977
	aurical.r15878
	b1encoding.r21271
	barcodes.r15878
	baskervaldadf.r72484
	baskervaldx.r71145
	baskervillef.r55475
	bbding.r17186
	bbm.r15878
	bbm-macros.r17224
	bbold.r17187
	bbold-type1.r33143
	bboldx.r65424
	belleek.r66115
	bera.r20031
	berenisadf.r72484
	beuron.r46374
	bguq.r27401
	bitter.r67598
	blacklettert1.r15878
	boisik.r15878
	bonum-otf.r71894
	bookhands.r46480
	boondox.r54512
	braille.r20655
	brushscr.r28363
	cabin.r68373
	caladea.r64549
	calligra.r15878
	calligra-type1.r24302
	cantarell.r54512
	carlito.r64624
	carolmin-ps.r15878
	cascadia-code.r68485
	cascadiamono-otf.r72257
	ccicons.r54512
	cfr-initials.r61719
	cfr-lm.r72484
	charissil.r64998
	cherokee.r21046
	chivo.r65029
	cinzel.r64550
	clara.r54512
	clearsans.r64400
	cm-lgc.r28250
	cm-mf-extra-bold.r54512
	cm-unicode.r58661
	cmathbb.r56414
	cmbright.r21107
	cmexb.r54074
	cmll.r17964
	cmpica.r15878
	cmsrb.r54706
	cmtiup.r39728
	cmupint.r54735
	cochineal.r70528
	coelacanth.r64558
	comfortaa.r54512
	comicneue.r54891
	concmath-fonts.r17218
	concmath-otf.r72660
	cookingsymbols.r35929
	cooperhewitt.r64967
	cormorantgaramond.r71057
	countriesofeurope.r54512
	courier-scaled.r24940
	courierten.r55436
	crimson.r64559
	crimsonpro.r64565
	cryst.r15878
	cuprum.r49909
	cyklop.r18651
	cyrillic-modern.r71183
	dancers.r13293
	dantelogo.r38599
	dejavu.r31771
	dejavu-otf.r45991
	dice.r28501
	dictsym.r69720
	dingbat.r27918
	domitian.r55286
	doublestroke.r15878
	doulossil.r63255
	dozenal.r47680
	drm.r38157
	droid.r54512
	dsserif.r60898
	duerer.r20741
	duerer-latex.r15878
	dutchcal.r54080
	ean.r20851
	ebgaramond.r71069
	ebgaramond-maths.r52168
	ecc.r15878
	eco.r29349
	eczar.r57716
	eiad.r15878
	eiad-ltx.r15878
	ektype-tanka.r63255
	electrumadf.r72484
	elvish.r15878
	epigrafica.r17210
	epsdice.r15878
	erewhon.r70759
	erewhon-math.r70295
	esrelation.r37236
	esstix.r22426
	esvect.r32098
	etbb.r69098
	euler-math.r70296
	eulervm.r15878
	euxm.r54074
	fbb.r55728
	fdsymbol.r61719
	fetamont.r43812
	feyn.r63945
	fge.r71737
	fira.r64422
	firamath.r56672
	firamath-otf.r68233
	foekfont.r15878
	fonetika.r21326
	fontawesome.r48145
	fontawesome5.r63207
	fontmfizz.r43546
	fonts-churchslavonic.r67473
	forum.r64566
	fourier.r72243
	fouriernc.r29646
	frcursive.r24559
	frederika2016.r42157
	frimurer.r56704
	garamond-libre.r71058
	garamond-math.r61481
	gelasio.r71047
	gelasiomath.r71883
	genealogy.r25112
	gentium-tug.r63470
	gfsartemisia.r19469
	gfsbodoni.r28484
	gfscomplutum.r19469
	gfsdidot.r69112
	gfsdidotclassic.r52778
	gfsneohellenic.r63944
	gfsneohellenicmath.r63928
	gfssolomos.r18651
	gillcm.r19878
	gillius.r64865
	gnu-freefont.r68624
	gofonts.r64358
	gothic.r49869
	greenpoint.r15878
	grotesq.r35859
	gudea.r57359
	hacm.r27671
	hamnosys.r61941
	hands.r13293
	hep-font.r67632
	hep-math-font.r67632
	heros-otf.r64695
	heuristica.r69649
	hfbright.r29349
	hfoldsty.r29349
	hindmadurai.r57360
	ibarra.r71059
	ifsym.r24868
	imfellenglish.r64568
	inconsolata.r54512
	inconsolata-nerd-font.r70871
	initials.r54080
	inriafonts.r54512
	inter.r68966
	ipaex-type1.r47700
	iwona.r19611
	jablantile.r16364
	jamtimes.r20408
	josefin.r64569
	junicode.r71871
	junicodevf.r71920
	kixfont.r18488
	kpfonts.r72680
	kpfonts-otf.r71153
	kurier.r19612
	lato.r54512
	lete-sans-math.r71836
	lexend.r57564
	lfb.r15878
	libertine.r72795
	libertinegc.r44616
	libertinus.r61719
	libertinus-fonts.r72484
	libertinus-otf.r68333
	libertinus-type1.r72354
	libertinust1math.r71428
	librebaskerville.r64421
	librebodoni.r64431
	librecaslon.r64432
	librefranklin.r64441
	libris.r72484
	lineara.r63169
	linguisticspro.r64858
	lobster2.r64442
	logix.r63688
	luwiantype.r71820
	lxfonts.r32354
	ly1.r63565
	magra.r57373
	marcellus.r64451
	mathabx.r15878
	mathabx-type1.r21129
	mathdesign.r31639
	mdputu.r20298
	mdsymbol.r28399
	merriweather.r64452
	metsymb.r68175
	mfb-oldstyle.r71982
	miama.r54512
	mintspirit.r64461
	missaali.r61719
	mlmodern.r57458
	mnsymbol.r18651
	montserrat.r54512
	mpfonts.r54512
	mweights.r53520
	newcomputermodern.r72735
	newpx.r72879
	newtx.r72368
	newtxsf.r69597
	newtxtt.r70620
	niceframe-type1.r71849
	nimbus15.r72894
	nkarta.r16437
	noto.r64351
	noto-emoji.r62950
	notomath.r71429
	nunito.r57429
	obnov.r33355
	ocherokee.r25689
	ocr-b.r20852
	ocr-b-outline.r20969
	ogham.r24876
	oinuit.r28668
	old-arrows.r42872
	oldlatin.r17932
	oldstandard.r70421
	opensans.r54512
	orkhun.r15878
	oswald.r60784
	overlock.r64495
	pacioli.r24947
	pagella-otf.r64705
	paratype.r68624
	phaistos.r18651
	phonetic.r56468
	pigpen.r69687
	playfair.r64857
	plex.r69154
	plex-otf.r68238
	plimsoll.r56605
	poiretone.r64856
	poltawski.r67718
	prodint.r21893
	punk.r27388
	punk-latex.r27389
	punknova.r24649
	pxtxalfa.r60847
	qualitype.r54512
	quattrocento.r64372
	raleway.r42629
	recycle.r15878
	rit-fonts.r67659
	roboto.r64350
	romandeadf.r72484
	rosario.r51688
	rsfso.r60849
	ruscap.r71123
	sansmathaccent.r53628
	sansmathfonts.r72563
	sauter.r13293
	sauterfonts.r15878
	schola-otf.r64734
	scholax.r61836
	schulschriften.r59388
	semaphor.r18651
	shobhika.r50555
	simpleicons.r72797
	skull.r51907
	sourcecodepro.r54512
	sourcesanspro.r54892
	sourceserifpro.r54512
	spectral.r64528
	srbtiks.r63308
	starfont.r19982
	staves.r15878
	step.r57307
	stepgreek.r57074
	stickstoo.r72368
	stix.r54512
	stix2-otf.r58735
	stix2-type1.r57448
	superiors.r69387
	svrsymbols.r50019
	symbats3.r63833
	tapir.r20484
	tempora.r39596
	tengwarscript.r34594
	termes-otf.r64733
	tfrupee.r20770
	theanodidot.r64518
	theanomodern.r64520
	theanooldstyle.r64519
	tinos.r68950
	tpslifonts.r42428
	trajan.r15878
	twemoji-colr.r71991
	txfontsb.r54512
	txuprcal.r43327
	typicons.r37623
	umtypewriter.r64443
	universa.r51984
	universalis.r64505
	uppunctlm.r42334
	urwchancal.r21701
	venturisadf.r72484
	wsuipa.r25469
	xcharter.r71564
	xcharter-math.r72658
	xits.r55730
	yfonts.r50755
	yfonts-otf.r65030
	yfonts-t1.r36013
	yinit-otf.r40207
	ysabeau.r72800
	zlmtt.r64076
"
TEXLIVE_MODULE_DOC_CONTENTS="
	aboensis.doc.r62977
	academicons.doc.r62622
	accanthis.doc.r64844
	adforn.doc.r72484
	adfsymbols.doc.r72458
	aesupp.doc.r58253
	alegreya.doc.r64384
	alfaslabone.doc.r57452
	algolrevived.doc.r71368
	allrunes.doc.r42221
	almendra.doc.r64539
	almfixed.doc.r35065
	andika.doc.r64540
	anonymouspro.doc.r51631
	antiqua.doc.r24266
	antt.doc.r18651
	archaic.doc.r38005
	archivo.doc.r57283
	arev.doc.r15878
	arimo.doc.r68950
	arsenal.doc.r68191
	arvo.doc.r57213
	asana-math.doc.r59629
	asapsym.doc.r40201
	ascii-font.doc.r29989
	aspectratio.doc.r25243
	astro.doc.r15878
	atkinson.doc.r71048
	augie.doc.r61719
	auncial-new.doc.r62977
	aurical.doc.r15878
	b1encoding.doc.r21271
	barcodes.doc.r15878
	baskervaldadf.doc.r72484
	baskervaldx.doc.r71145
	baskervillef.doc.r55475
	bbding.doc.r17186
	bbm.doc.r15878
	bbm-macros.doc.r17224
	bbold.doc.r17187
	bbold-type1.doc.r33143
	bboldx.doc.r65424
	belleek.doc.r66115
	bera.doc.r20031
	berenisadf.doc.r72484
	beuron.doc.r46374
	bguq.doc.r27401
	bitter.doc.r67598
	blacklettert1.doc.r15878
	boisik.doc.r15878
	bonum-otf.doc.r71894
	bookhands.doc.r46480
	boondox.doc.r54512
	braille.doc.r20655
	brushscr.doc.r28363
	cabin.doc.r68373
	caladea.doc.r64549
	calligra.doc.r15878
	calligra-type1.doc.r24302
	cantarell.doc.r54512
	carlito.doc.r64624
	carolmin-ps.doc.r15878
	cascadia-code.doc.r68485
	cascadiamono-otf.doc.r72257
	ccicons.doc.r54512
	cfr-initials.doc.r61719
	cfr-lm.doc.r72484
	charissil.doc.r64998
	cherokee.doc.r21046
	chivo.doc.r65029
	cinzel.doc.r64550
	clara.doc.r54512
	clearsans.doc.r64400
	cm-lgc.doc.r28250
	cm-unicode.doc.r58661
	cmathbb.doc.r56414
	cmbright.doc.r21107
	cmexb.doc.r54074
	cmll.doc.r17964
	cmpica.doc.r15878
	cmsrb.doc.r54706
	cmtiup.doc.r39728
	cmupint.doc.r54735
	cochineal.doc.r70528
	coelacanth.doc.r64558
	comfortaa.doc.r54512
	comicneue.doc.r54891
	concmath-fonts.doc.r17218
	concmath-otf.doc.r72660
	cookingsymbols.doc.r35929
	cooperhewitt.doc.r64967
	cormorantgaramond.doc.r71057
	countriesofeurope.doc.r54512
	courier-scaled.doc.r24940
	courierten.doc.r55436
	crimson.doc.r64559
	crimsonpro.doc.r64565
	cryst.doc.r15878
	cuprum.doc.r49909
	cyklop.doc.r18651
	cyrillic-modern.doc.r71183
	dantelogo.doc.r38599
	dejavu.doc.r31771
	dejavu-otf.doc.r45991
	dice.doc.r28501
	dictsym.doc.r69720
	dingbat.doc.r27918
	domitian.doc.r55286
	doublestroke.doc.r15878
	doulossil.doc.r63255
	dozenal.doc.r47680
	drm.doc.r38157
	droid.doc.r54512
	dsserif.doc.r60898
	duerer.doc.r20741
	duerer-latex.doc.r15878
	dutchcal.doc.r54080
	ean.doc.r20851
	ebgaramond.doc.r71069
	ebgaramond-maths.doc.r52168
	ecc.doc.r15878
	eco.doc.r29349
	eczar.doc.r57716
	eiad.doc.r15878
	eiad-ltx.doc.r15878
	ektype-tanka.doc.r63255
	electrumadf.doc.r72484
	elvish.doc.r15878
	epigrafica.doc.r17210
	epsdice.doc.r15878
	erewhon.doc.r70759
	erewhon-math.doc.r70295
	esrelation.doc.r37236
	esstix.doc.r22426
	esvect.doc.r32098
	etbb.doc.r69098
	euler-math.doc.r70296
	eulervm.doc.r15878
	fbb.doc.r55728
	fdsymbol.doc.r61719
	fetamont.doc.r43812
	feyn.doc.r63945
	fge.doc.r71737
	fira.doc.r64422
	firamath.doc.r56672
	firamath-otf.doc.r68233
	foekfont.doc.r15878
	fonetika.doc.r21326
	fontawesome.doc.r48145
	fontawesome5.doc.r63207
	fontmfizz.doc.r43546
	fonts-churchslavonic.doc.r67473
	fontscripts.doc.r72672
	forum.doc.r64566
	fourier.doc.r72243
	fouriernc.doc.r29646
	frcursive.doc.r24559
	frederika2016.doc.r42157
	frimurer.doc.r56704
	garamond-libre.doc.r71058
	garamond-math.doc.r61481
	gelasio.doc.r71047
	gelasiomath.doc.r71883
	genealogy.doc.r25112
	gentium-tug.doc.r63470
	gfsartemisia.doc.r19469
	gfsbodoni.doc.r28484
	gfscomplutum.doc.r19469
	gfsdidot.doc.r69112
	gfsdidotclassic.doc.r52778
	gfsneohellenic.doc.r63944
	gfsneohellenicmath.doc.r63928
	gfssolomos.doc.r18651
	gillcm.doc.r19878
	gillius.doc.r64865
	gnu-freefont.doc.r68624
	gofonts.doc.r64358
	gothic.doc.r49869
	greenpoint.doc.r15878
	grotesq.doc.r35859
	gudea.doc.r57359
	hacm.doc.r27671
	hamnosys.doc.r61941
	hep-font.doc.r67632
	hep-math-font.doc.r67632
	heros-otf.doc.r64695
	heuristica.doc.r69649
	hfbright.doc.r29349
	hfoldsty.doc.r29349
	hindmadurai.doc.r57360
	ibarra.doc.r71059
	ifsym.doc.r24868
	imfellenglish.doc.r64568
	inconsolata.doc.r54512
	inconsolata-nerd-font.doc.r70871
	initials.doc.r54080
	inriafonts.doc.r54512
	inter.doc.r68966
	ipaex-type1.doc.r47700
	iwona.doc.r19611
	jablantile.doc.r16364
	jamtimes.doc.r20408
	josefin.doc.r64569
	junicode.doc.r71871
	junicodevf.doc.r71920
	kixfont.doc.r18488
	kpfonts.doc.r72680
	kpfonts-otf.doc.r71153
	kurier.doc.r19612
	lato.doc.r54512
	lete-sans-math.doc.r71836
	lexend.doc.r57564
	lfb.doc.r15878
	libertine.doc.r72795
	libertinegc.doc.r44616
	libertinus.doc.r61719
	libertinus-fonts.doc.r72484
	libertinus-otf.doc.r68333
	libertinus-type1.doc.r72354
	libertinust1math.doc.r71428
	librebaskerville.doc.r64421
	librebodoni.doc.r64431
	librecaslon.doc.r64432
	librefranklin.doc.r64441
	libris.doc.r72484
	lineara.doc.r63169
	linguisticspro.doc.r64858
	lobster2.doc.r64442
	logix.doc.r63688
	luwiantype.doc.r71820
	lxfonts.doc.r32354
	ly1.doc.r63565
	magra.doc.r57373
	marcellus.doc.r64451
	mathabx.doc.r15878
	mathabx-type1.doc.r21129
	mathdesign.doc.r31639
	mdputu.doc.r20298
	mdsymbol.doc.r28399
	merriweather.doc.r64452
	metsymb.doc.r68175
	mfb-oldstyle.doc.r71982
	miama.doc.r54512
	mintspirit.doc.r64461
	missaali.doc.r61719
	mlmodern.doc.r57458
	mnsymbol.doc.r18651
	montserrat.doc.r54512
	mpfonts.doc.r54512
	mweights.doc.r53520
	newcomputermodern.doc.r72735
	newpx.doc.r72879
	newtx.doc.r72368
	newtxsf.doc.r69597
	newtxtt.doc.r70620
	niceframe-type1.doc.r71849
	nimbus15.doc.r72894
	nkarta.doc.r16437
	noto.doc.r64351
	noto-emoji.doc.r62950
	notomath.doc.r71429
	nunito.doc.r57429
	obnov.doc.r33355
	ocherokee.doc.r25689
	ocr-b.doc.r20852
	ocr-b-outline.doc.r20969
	ogham.doc.r24876
	oinuit.doc.r28668
	old-arrows.doc.r42872
	oldlatin.doc.r17932
	oldstandard.doc.r70421
	opensans.doc.r54512
	orkhun.doc.r15878
	oswald.doc.r60784
	overlock.doc.r64495
	pacioli.doc.r24947
	pagella-otf.doc.r64705
	paratype.doc.r68624
	phaistos.doc.r18651
	phonetic.doc.r56468
	pigpen.doc.r69687
	playfair.doc.r64857
	plex.doc.r69154
	plex-otf.doc.r68238
	plimsoll.doc.r56605
	poiretone.doc.r64856
	poltawski.doc.r67718
	prodint.doc.r21893
	punk.doc.r27388
	punk-latex.doc.r27389
	punknova.doc.r24649
	pxtxalfa.doc.r60847
	qualitype.doc.r54512
	quattrocento.doc.r64372
	raleway.doc.r42629
	recycle.doc.r15878
	rit-fonts.doc.r67659
	roboto.doc.r64350
	romandeadf.doc.r72484
	rosario.doc.r51688
	rsfso.doc.r60849
	ruscap.doc.r71123
	sansmathaccent.doc.r53628
	sansmathfonts.doc.r72563
	sauterfonts.doc.r15878
	schola-otf.doc.r64734
	scholax.doc.r61836
	schulschriften.doc.r59388
	semaphor.doc.r18651
	shobhika.doc.r50555
	simpleicons.doc.r72797
	sourcecodepro.doc.r54512
	sourcesanspro.doc.r54892
	sourceserifpro.doc.r54512
	spectral.doc.r64528
	srbtiks.doc.r63308
	starfont.doc.r19982
	staves.doc.r15878
	step.doc.r57307
	stepgreek.doc.r57074
	stickstoo.doc.r72368
	stix.doc.r54512
	stix2-otf.doc.r58735
	stix2-type1.doc.r57448
	superiors.doc.r69387
	svrsymbols.doc.r50019
	symbats3.doc.r63833
	tapir.doc.r20484
	tempora.doc.r39596
	tengwarscript.doc.r34594
	termes-otf.doc.r64733
	tfrupee.doc.r20770
	theanodidot.doc.r64518
	theanomodern.doc.r64520
	theanooldstyle.doc.r64519
	tinos.doc.r68950
	tpslifonts.doc.r42428
	trajan.doc.r15878
	twemoji-colr.doc.r71991
	txfontsb.doc.r54512
	txuprcal.doc.r43327
	typicons.doc.r37623
	umtypewriter.doc.r64443
	universa.doc.r51984
	universalis.doc.r64505
	uppunctlm.doc.r42334
	urwchancal.doc.r21701
	venturisadf.doc.r72484
	wsuipa.doc.r25469
	xcharter.doc.r71564
	xcharter-math.doc.r72658
	xits.doc.r55730
	yfonts.doc.r50755
	yfonts-otf.doc.r65030
	yfonts-t1.doc.r36013
	yinit-otf.doc.r40207
	ysabeau.doc.r72800
	zlmtt.doc.r64076
"
TEXLIVE_MODULE_SRC_CONTENTS="
	adforn.source.r72484
	adfsymbols.source.r72458
	aesupp.source.r58253
	allrunes.source.r42221
	anonymouspro.source.r51631
	archaic.source.r38005
	arev.source.r15878
	arsenal.source.r68191
	asapsym.source.r40201
	ascii-font.source.r29989
	auncial-new.source.r62977
	b1encoding.source.r21271
	barcodes.source.r15878
	baskervaldadf.source.r72484
	bbding.source.r17186
	bbm-macros.source.r17224
	bbold.source.r17187
	belleek.source.r66115
	berenisadf.source.r72484
	bguq.source.r27401
	blacklettert1.source.r15878
	bookhands.source.r46480
	ccicons.source.r54512
	cfr-lm.source.r72484
	chivo.source.r65029
	cmbright.source.r21107
	cmll.source.r17964
	cookingsymbols.source.r35929
	dingbat.source.r27918
	dozenal.source.r47680
	drm.source.r38157
	dsserif.source.r60898
	eco.source.r29349
	eiad-ltx.source.r15878
	electrumadf.source.r72484
	epsdice.source.r15878
	esrelation.source.r37236
	esvect.source.r32098
	eulervm.source.r15878
	fdsymbol.source.r61719
	fetamont.source.r43812
	feyn.source.r63945
	fge.source.r71737
	fontscripts.source.r72672
	frimurer.source.r56704
	gentium-tug.source.r63470
	gnu-freefont.source.r68624
	gothic.source.r49869
	hamnosys.source.r61941
	hep-font.source.r67632
	hep-math-font.source.r67632
	hfoldsty.source.r29349
	inconsolata-nerd-font.source.r70871
	libris.source.r72484
	lineara.source.r63169
	lxfonts.source.r32354
	mdsymbol.source.r28399
	metsymb.source.r68175
	miama.source.r54512
	mnsymbol.source.r18651
	newpx.source.r72879
	nkarta.source.r16437
	ocr-b-outline.source.r20969
	oinuit.source.r28668
	pacioli.source.r24947
	phaistos.source.r18651
	plimsoll.source.r56605
	romandeadf.source.r72484
	rosario.source.r51688
	sauterfonts.source.r15878
	skull.source.r51907
	staves.source.r15878
	stix.source.r54512
	stix2-type1.source.r57448
	svrsymbols.source.r50019
	tengwarscript.source.r34594
	tfrupee.source.r20770
	tpslifonts.source.r42428
	trajan.source.r15878
	txfontsb.source.r54512
	universa.source.r51984
	venturisadf.source.r72484
	yfonts.source.r50755
"

inherit texlive-module

DESCRIPTION="TeXLive Additional fonts"

LICENSE="Apache-2.0 BSD BSD-2 CC-BY-1.0 CC-BY-4.0 CC-BY-SA-4.0 CC0-1.0 FDL-1.1+ GPL-1+ GPL-2 GPL-2+ GPL-3 GPL-3+ LPPL-1.0 LPPL-1.2 LPPL-1.3 LPPL-1.3c MIT OFL-1.1 TeX TeX-other-free public-domain"
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
