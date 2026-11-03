# Configuration

A guide to configuring `tails.scad`, all the different settings and their effects and the feedback the model reports back to you.

There are three ways to set things:

* **Customizer:** open `tails.scad` in OpenSCAD (or the playground) and use the Parameters panel.
  The sliders are limited to the ranges below.
* **Command line:** override any of the capitalised parameters with `-D`, for example
  `openscad -D SPAN=220 -D ROOT_CHORD=30 -o tail.stl tails.scad`.
  The slider ranges don't apply here.
* **The `tail()` module:** `use` the file from your own `.scad` and call `tail(span, root_chord, ...)`.
  This also gives you a few options that aren't in the customizer (see [Module-only options](#module-only-options)).


## Up and down - understanding this guide

This document is written with up and down meaning as ridden. With the board up and foil and fuse and stab down the top of the stab is the top in this document. This differs from the NACA profiles which are run "upside down" since the function of the stabiliser is to produce downforce to counteract the natural pitch down of the main foil. In contrast, the main foil is oriented the conventional way. For axis mount stabilisers that means the mount is underneath and the screw hole countersinks are on top.

In the code, names like `naca_top` and `wing_top` follow NACA, so "top" there is the underside as ridden, which only matters if you're changing the code.


## Mount

| Parameter | Default  | Range    |                              |
|-----------|----------|----------|------------------------------|
| `MOUNT`   | `"axis"` | `"axis"` | Which fuselage the tail fits |

Axis is the only mount so far.
It's a 90mm long, 10mm deep block under the root of the foil with two M6 countersunk screw holes, 23mm and 58mm back from its front.
The countersinks are in the top of the foil, and their depth is worked out from the shape of that surface.

The mount is the same size whatever the foil. Every root chord in range is shorter than the mount, so the back of the mount always sits behind the trailing edge.


## Foil

| Parameter             | Default    | Range                   | Units                                         |
|-----------------------|------------|-------------------------|-----------------------------------------------|
| `SPAN`                | 225        | 100 to 280, step 5      | mm                                            |
| `ROOT_CHORD`          | 45         | 20 to 60, step 1        | mm                                            |
| `FOIL_FAMILY`         | `"NACA-4"` | `"NACA-4"`              |                                               |
| `MAX_THICKNESS`       | 0.1        | 0.04 to 0.2, step 0.005 | fraction of local chord                       |
| `MAX_CAMBER`          | 0.02       | 0 to 0.1, step 0.005    | fraction of local chord                       |
| `MAX_CAMBER_POSITION` | 0.4        | 0.2 to 0.7, step 0.05   | fraction of local chord from the leading edge |
| `REFERENCE_LINE`      | 0.4        | 0 to 2, step 0.05       | fraction of local chord from the leading edge |
| `DROOP`               | 3          | -10 to 10, step 0.5     | mm                                            |
| `TWIST`               | 0          | -10 to 10, step 0.5     | degrees                                       |

### `SPAN` and `ROOT_CHORD`

The planform is elliptical: the chord at any point is `ROOT_CHORD × cos(a)`, where `sin(a)` is the distance from the centre as a fraction of half the span.

The foil is built from sections every 5° of `a`, out to 85°.
That means the tips are cut off slightly short of a point: the actual tip-to-tip span is about 99.6% of `SPAN`, and each tip is a flat end about 9% of `ROOT_CHORD` long (4mm on the default tail).

### `FOIL_FAMILY`

Only 4-digit NACA sections so far.
The same section is used all the way out, scaled to the local chord.

### `MAX_THICKNESS`, `MAX_CAMBER` and `MAX_CAMBER_POSITION`

These are the three numbers of a NACA 4-digit section, and the model names the foil the same way: `N` + camber in % + camber position in tenths + thickness in %.
The defaults (2%, 0.4, 10%) give `N2410`.
The name is rounded, so `MAX_CAMBER_POSITION = 0.45` is labelled as `5`.

* `MAX_THICKNESS` is the thickest point as a fraction of chord, so the default root is 4.5mm thick.
  The thickness scales with chord, so the tips get very thin: 10% of a 4mm tip is 0.4mm.
* `MAX_CAMBER` is how far the mean line bows downwards (towards the mount), as a fraction of chord.
  More camber means more downforce, and 0 is a symmetric section.
  A negative value (command line only) bows it upwards, which makes the tail lift.
* `MAX_CAMBER_POSITION` is where along the chord that bow peaks.

### `REFERENCE_LINE` (sweep)

Each section is positioned so that the point `REFERENCE_LINE` of the way back along its chord lies on one straight line across the span, through the same point on the root.

* `0`: the leading edge is straight and the trailing edge curves forward (in the direction of travel) towards the tips.
* `1`: the trailing edge is straight and the leading edge curves back.
* In between: both edges curve. 0.25 keeps the quarter-chord line straight, which is the usual definition of unswept.
* Above `1`: the reference line is behind the trailing edge, so both edges sweep back towards the tips.
  Bigger numbers sweep further.

The root is always in the same place relative to the mount (leading edge at the front of the mount); only the outer sections move.

### `DROOP`

How far the tips move in or out of plane, in mm, relative to the root.
Positive moves the tips down, negative moves them up.

The offset grows as `1 - cos(a)` (same `a` as above), so the inner foil stays nearly flat and it bends more towards the tips.
The last section reaches about 91% of the number you set.

### `TWIST`

How far the tips rotate relative to the root, in degrees, about the reference line.
Positive moves the trailing edge down and the leading edge up, so the tips are nose up compared to the root (less downforce at the tips).
Negative makes them nose down (more downforce at the tips).

It follows the same `1 - cos(a)` curve as droop, so the root is untwisted and the last section reaches about 91% of the number you set.


## Text

| Parameter    | Default | Range              | Units |
|--------------|---------|--------------------|-------|
| `SHOW_TEXT`  | `true`  |                    |       |
| `TEXT_SIZE`  | 3       | 1 to 10            | mm    |
| `TEXT_DEPTH` | 0.5     | 0.1 to 2, step 0.1 | mm    |

When `SHOW_TEXT` is on, four labels are engraved `TEXT_DEPTH` deep into the top of the tail (the side away from the mount), over the back of the mount:

* span x root chord, e.g. `225x45`
* plan area, e.g. `80 cm²`
* aspect ratio, e.g. `AR 6.4`
* foil name, e.g. `N2410`, further back

The first three are 48mm back from the front of the mount and the name is at 80mm.
On a root chord longer than 48mm the first three land on the foil itself rather than the mount.


## What the model reports

Each render prints a summary to the OpenSCAD console:

```
  shape: N2410
  span x root chord: 225mm x 45mm
  plan area: 79.5216cm^2
  aspect ratio: 6.3662
  mean chord: 35.3429mm
  mean thickness: 2.42094mm
```

* **plan area** is the area of the full ellipse, `π/4 × SPAN × ROOT_CHORD`.
  It ignores the trimmed tips (a fraction of a percent) and the mount.
* **aspect ratio** is `SPAN² / plan area`.
* **mean chord** is `plan area / SPAN`.
* **mean thickness** is the foil's cross-section area divided by its chord, at the mean chord.
  It's a better guide to how stiff a section is than the maximum thickness.


## Printing orientation

The model comes out the way it's printed: leading edge down (on the print bed, not as ridden), tilted back 20°.
That's fixed in the code (the two `rotate`s at the top of the file); see the readme for why.


## Module-only options

`tail()` takes all the parameters above in lower case (`max_thickness`, `droop`, and so on), plus a few that aren't in the customizer:

| Argument      | Default                |                                                                                                            |
|---------------|------------------------|------------------------------------------------------------------------------------------------------------|
| `plan_form`   | `"elliptical"`         | `"rect"` gives a constant chord equal to the elliptical tail's mean chord, so the plan area stays the same |
| `font`        | `"Tahoma: style=Bold"` | Font for the labels. If it isn't installed OpenSCAD falls back to its default font                         |
| `point_count` | 82                     | Points around each foil section, half on each surface, bunched up at the leading and trailing edges        |

The hidden `$fs = 0.1` sets OpenSCAD's minimum facet size, which mostly affects the screw holes and the text.


## Adding a mount or a foil family

Mounts live in the `MOUNTS` table. Each one has:

* `profile`: the side view of the mount block as `[x, y]` points, x back from the front of the mount and y how far the block reaches down from the foil's chord line (negative, since it's below the chord line; the Axis block runs from 0 to -10)
* `half_plan`: one side of the mount's outline from above, as `[x, half width]` points, mirrored to make the other side
* `screw_holes`: a list of `location` (mm back from the front) and `size` (a BOSL2 screw size like `"M6"`)

Both outlines get their corners rounded. Adding a mount also means adding it to the `MOUNT` options at the top of the file.

Foil families live in the `FOILS` table, as four functions: `name`, `profile` (the whole section as points), and `top` and `bottom` (one surface at a given fraction of chord; NACA terms, so `top` is the underside as ridden).
Adding one also means adding it to the `FOIL_FAMILY` options at the top of the file.
