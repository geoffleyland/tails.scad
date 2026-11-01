# `tails.scad`

`tails.scad` is a parametric [OpenSCAD](https://openscad.org/) model for 3D-printed pumpfoil stabilisers.

<p align="center"><img src="tails.png" width="300" alt="A pumpfoil tail"></p>
    
You might think that home printing tails in PLA will never work, and so did I.
I was pretty happy when I found out I was wrong.

The tails have 4-digit NACA profiles and are Axis-compatible (see Contributing below!).

You can adjust foil span, root chord, thickness, camber and maximum camber location, angle of attack, sweep, droop and twist.
At some stage I'll get to implementing planforms other than elliptical,
and maybe some more exotic foil profiles.


## Safety and Legal
Pumpfoiling is dangerous and printed tails may break.  Use at your own risk.

This code is MIT licensed. Provided as is, with no warranty.

I'm not affiliated with or endorsed by any foil manufacturer or company mentioned:
"(manufacturer)-compatible" just means it fits their gear.


## Using the model

You need access to a printer and someone who knows how to use it and drive the slicer.

### Option 1: Use OpenSCAD
* Download a nightly build of [OpenSCAD](https://openscad.org/downloads.html#snapshots).
* Install [BOSL2](https://github.com/BelfrySCAD/BOSL2/#installation).
* Open `tails.scad`.
* Go nuts.

### Option 2: Use [OpenSCAD Playground](https://www.devtoolsdaily.com/openscad/playground/)
* Copy-paste `tails.scad` into the code window in the playground.
* Find the "Files" tab on the right, scroll down, and select `Enable BOSL2`
* Switch the right-hand tab back to "Parameters".
* Play.

### Option 3: Use [MakerWorld](https://makerworld.com/en)
I'll put a link here once I've got that sorted.


## Printing
I just print in plain PLA - my printer is open so it's not great for more exotic materials - and PLA works fine.
If you print one in PPA-CF, sinter one in titanium or machine one out of a billet of aluminium, I'd love to hear about that!

The model should appear in your slicer in the orientation I print: leading edge down, tilted 20° back (20° is small enough that my slicer doesn't decide to support the whole thing, it seems to make the leading edge a bit tidier, and I figure that not having vertical layers might help around the screw holes - but they still break at the rear screw).

Print with enough wall loops that there's no infill at all (10?).
That way the extrusion is aligned with the load paths.


## What Tail Should I Print?

<p align="center"><img src="tails.jpg" width="300" alt="Lots of tails"></p>

Don't overthink it.  A tail is about $1 (NZ) of PLA.  Print a heap and try them.
We go down to the dock with a dozen or so, some are good, some are bad, some break.
Some of the bad ones turn out to be good ones on the next session.
I've tried rectangular planforms (surprisingly good, but really squeaky) and a rectangular foil profile (awful).

I've been surprised how quickly we've got down to what I thought were tiny tails
(about 200x25) and that tails that thin work at all in PLA, so don't be scared of going small.
If you start successfully twice in a row on a tail, try the next one down :-).

Playing with camber is fun: on my setup 0% camber nosedives on nearly every launch,
but 4% is nearly un-pumpable because there's too much tail lift.

But, if you're looking for a safe starting point, try 225mm span x 45mm root chord N2410, which is the default.

Let me know what works for you!


## Contributing
I only have access to [Axis](https://axisfoils.com/) gear,
so you're welcome to contribute mounts for other equipment.

If you are going to contribute, please keep your PRs small and single-purpose.
I will read your PR, so please have the courtesy to read and understand it yourself.
