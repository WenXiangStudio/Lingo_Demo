# British phoneme audio contract

This directory contains the 44 British English phoneme recordings used by the
phonetics screen. They were mapped by IPA symbol from the source archive at
`D:\LingoDemoData\source_archives\cambridge_ipa_44.zip`, then converted from
stereo Opus to mono, 16-bit PCM WAV at 48 kHz.

Source archive SHA-256:
`ABB37535A8B8592C8C741720E7CDD9727153B6D6DC47622C4C185A9B2A39ECB5`.

Required format: mono, 16-bit PCM WAV, 44.1 kHz or 48 kHz.

The file names are the `id` values in
`lib/features/phonetics/data/british_phoneme_catalog.dart`, followed by
`.wav`. The application does not fall back to cloud TTS when a file is
missing.

## Required files

Monophthongs:

`i_long.wav`, `i_short.wav`, `u_short.wav`, `u_long.wav`, `e.wav`,
`schwa.wav`, `er_long.wav`, `or_long.wav`, `ae.wav`, `uh.wav`, `a_long.wav`,
`o_short.wav`

Diphthongs:

`near.wav`, `face.wav`, `tour.wav`, `choice.wav`, `goat.wav`, `square.wav`,
`price.wav`, `mouth.wav`

Consonants:

`p.wav`, `b.wav`, `t.wav`, `d.wav`, `ch.wav`, `j_affricate.wav`, `k.wav`,
`g.wav`, `f.wav`, `v.wav`, `th_unvoiced.wav`, `th_voiced.wav`, `s.wav`,
`z.wav`, `sh.wav`, `zh.wav`, `m.wav`, `n.wav`, `ng.wav`, `h.wav`, `l.wav`,
`r.wav`, `w.wav`, `y.wav`
