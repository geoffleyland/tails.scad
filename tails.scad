// Copyright 2026 Geoff Leyland and contributors
// SPDX-License-Identifier: MIT

// See https://github.com/geoffleyland/tails.scad

include <BOSL2/std.scad>
include <BOSL2/screws.scad>

/* [Hidden] */
$fs=0.1;

/* [Mount] */
MOUNT = "axis";                 // ["axis"]
/* [Foil parameters] */
// (mm)
SPAN = 225;                     // [100:5:280]
// (mm)
ROOT_CHORD = 45;                // [20:1:90]
// (mm)
TIP_CHORD = 4;                  // [3:1:70]
FOIL_FAMILY = "NACA-4";         // ["NACA-4"]
// (Fraction of local chord)
MAX_THICKNESS = 0.1;            // [0.04:0.005:0.2]
// (Fraction of local chord)
MAX_CAMBER = 0.02;              // [0.0:0.005:0.1]
// (Fraction of local chord from leading edge)
MAX_CAMBER_POSITION = 0.4;      // [0.2:0.05:0.7]
// (Degrees. Negative pushes the tail down)
ANGLE_OF_ATTACK = 0.0;          // [-2:0.25:2]
// (Affects sweep, fraction of local chord from leading edge)
REFERENCE_LINE = 0.4;           // [0:0.05:2]
// (Shape: 1 = trapezoid, 2 = ellipse, experiment!)
PLAN_FORM_EXPONENT = 2.0;       // [1:0.2:10]
// (mm)
DROOP = 3;                      // [-10:0.5:10]
// (degrees)
TWIST = 0;                      // [-10:0.5:10]

/* [Text] */
SHOW_TEXT = true;
TEXT_SIZE = 3;                  // [1:10]
TEXT_DEPTH = 0.5;               // [0.1:0.1:2]


rotate([0, -90, 0]) rotate([0, 0, -20])
    tail(
        SPAN,
        ROOT_CHORD,
        tip_chord = TIP_CHORD,
        mount = MOUNT,
        foil_family = FOIL_FAMILY,
        max_thickness = MAX_THICKNESS,
        max_camber = MAX_CAMBER,
        max_camber_position = MAX_CAMBER_POSITION,
        angle_of_attack = ANGLE_OF_ATTACK,
        reference_line = REFERENCE_LINE,
        plan_form_exponent = PLAN_FORM_EXPONENT,
        droop = DROOP,
        twist = TWIST,

        show_text = SHOW_TEXT,
        text_size = TEXT_SIZE,
        text_depth = TEXT_DEPTH
    );


//- MOUNT OPTIONS ---------------------------------------------------------------------------------

MOUNTS = [
    ["axis", [
        ["profile", [[90,0],[0,0],[0,-1],[2,-3.5],[8,-6.5],[15,-8.5],[23,-9.5],[30,-10],[90,-10]] ],
        ["half_plan", [[90,1],[70,4.5],[35,10],[23,11],[13,10.5],[7,9],[4.5,8],[2,6.5],[1,4.5],[0,1]] ],
        ["screw_holes", [
            [["location", 23], ["size", "M6"]],
            [["location", 58], ["size", "M6"]],
        ]]
    ]]
];


//- NACA FOILS ------------------------------------------------------------------------------------

function naca_front_camber(x, max_camber, max_camber_position) =
    max_camber / max_camber_position^2 *
    (2 * max_camber_position * x - x^2);

function naca_front_camber_gradient(x, max_camber, max_camber_position) =
    2 * max_camber / max_camber_position^2 *
    (max_camber_position - x);

function naca_back_camber(x, max_camber, max_camber_position) =
    max_camber / (1 - max_camber_position)^2 *
    (1 + 2 * max_camber_position * (x - 1) - x^2);

function naca_back_camber_gradient(x, max_camber, max_camber_position) =
    2 * max_camber / (1 - max_camber_position)^2 *
    (max_camber_position - x);

function naca_camber(x, max_camber, max_camber_position) =
    x < max_camber_position ?
        naca_front_camber(x, max_camber, max_camber_position) :
        naca_back_camber(x, max_camber, max_camber_position);

function naca_camber_gradient(x, max_camber, max_camber_position) =
    x < max_camber_position ?
        naca_front_camber_gradient(x, max_camber, max_camber_position) :
        naca_back_camber_gradient(x, max_camber, max_camber_position);

/* [Hidden] */
NACA_A0 =  0.2969;
NACA_A1 = -0.1260;
NACA_A2 = -0.3516;
NACA_A3 =  0.2843;
NACA_A4 = -0.1015;

function naca_half_thickness(x, max_thickness) =
    max_thickness / 0.2 * (
        NACA_A0 * x^0.5 +
        NACA_A1 * x +
        NACA_A2 * x^2 +
        NACA_A3 * x^3 +
        NACA_A4 * x^4);

naca_point = function(x, parameters, side)
    let (
        max_camber = struct_val(parameters, "max_camber"),
        max_camber_position = struct_val(parameters, "max_camber_position"),
        max_thickness = struct_val(parameters, "max_thickness")
    )
    let (
        half_thickness = naca_half_thickness(x, max_thickness),
        camber = naca_camber(x, max_camber, max_camber_position),
        camber_gradient = naca_camber_gradient(x, max_camber, max_camber_position),
        theta = atan(camber_gradient)
    )
    [x - side * half_thickness * sin(theta), camber + side * half_thickness * cos(theta)];

naca_surfaces = function(parameters)
    let (
        n = floor(struct_val(parameters, "point_count") / 2),
        xs = [for (i = [0 : n-1]) (1 - cos(180 * i / (n-1))) / 2]
    )
    [
        [for (x = xs) naca_point(x, parameters,  1)],
        [for (x = xs) naca_point(x, parameters, -1)]
    ];


naca_name = function(parameters)
    let (
        max_camber = struct_val(parameters, "max_camber"),
        max_camber_position = struct_val(parameters, "max_camber_position"),
        max_thickness = struct_val(parameters, "max_thickness")
    )
    str("N", round(max_camber*100), round(max_camber_position * 10), format_int(round(max_thickness * 100),2));


//-------------------------------------------------------------------------------------------------

FOILS = [
    ["NACA-4", [
        ["name", naca_name],
        ["surfaces", naca_surfaces]
    ]]
];


//-------------------------------------------------------------------------------------------------

function join_surfaces(surfaces) =
    concat(reverse(surfaces[0]), [for (i = [1 : len(surfaces[1]) - 1]) surfaces[1][i]]);

function wing_section(foil_surfaces, chord, centre, twist, droop) =
    move([0, droop], scale(chord, zrot(twist, move([-centre, 0], join_surfaces(foil_surfaces)))));

function wing_surfaces(y, foil_surfaces, chord, centre, twist, droop) =
    let (
        root_section = move([centre * chord, 0], wing_section(foil_surfaces, chord, centre, twist, droop)),
        zs = [for (seg = polygon_line_intersection(root_section, [[y, -100], [y, 100]])) for (p = seg) p.y]
        )
        zs == [] ? [0,0] : [min(zs), max(zs)];


//-------------------------------------------------------------------------------------------------

module tail_screw_hole(y, size, foil_surfaces, parameters, mount_web) {
    info = screw_info(size, head="flat");
    head_d = struct_val(info, "head_size_sharp");
    head_r = head_d / 2;
    root_chord = struct_val(parameters, "root_chord");
    reference_line = struct_val(parameters, "reference_line");
    angle_of_attack = struct_val(parameters, "angle_of_attack");
    z = min(0, min([for (y1 = [y - head_r: 0.5: y + head_r])
        min(
            wing_surfaces(y1, foil_surfaces, root_chord, reference_line, angle_of_attack, 0)[0],
            let (zs = [for (seg = polygon_line_intersection(mount_web, [[y1, -100], [y1, 100]])) for (p = seg) p.y])
                zs == [] ? 0 : -max(zs)
        )
    ]));
    right(y) fwd(z) rotate([-90,0,0])
        screw_hole(size, head="flat", length=20, counterbore=1.5, head_oversize=-1, anchor="top");
}


//-------------------------------------------------------------------------------------------------

module tail(
    span,
    root_chord,
    tip_chord               = 4,
    mount                   = "axis",
    foil_family             = "NACA-4",
    max_thickness           = 0.1,
    max_camber              = 0.02,
    max_camber_position     = 0.4,
    angle_of_attack         = 0.0,
    reference_line          = 0.4,
    plan_form_exponent      = 2,
    droop                   = 3,
    twist                   = 0,
    show_text               = true,
    text_size               = 3,
    text_depth              = 0.5,
    font                    = "Tahoma: style=Bold",
    point_count             = 82) {

    // Prepare the mount
    MOUNT_INFO = struct_val(MOUNTS, mount);
    mount_profile = smooth_path(struct_val(MOUNT_INFO, "profile"), method="corners", relsize=1);
    mount_half_plan = struct_val(MOUNT_INFO, "half_plan");
    mount_plan_points = concat(mount_half_plan, reverse([for (p = mount_half_plan) [p.x, -p.y]]));
    mount_plan = smooth_path(mount_plan_points, method="corners", relsize=1);

    // Get the foil info
    FOIL_INFO = (struct_val(FOILS, foil_family));

    foil_parameters = [
        ["root_chord",          root_chord],
        ["max_thickness",       max_thickness],
        ["max_camber",          max_camber],
        ["max_camber_position", max_camber_position],
        ["angle_of_attack",     angle_of_attack],
        ["reference_line",      reference_line],
        ["point_count",         point_count]
    ];

    foil_name = (struct_val(FOIL_INFO, "name"))(foil_parameters);
    foil_surfaces = (struct_val(FOIL_INFO, "surfaces"))(foil_parameters);

    // Figure out some foil parameters
    mean_thickness = polygon_area(join_surfaces(foil_surfaces));
    square_profile = [[1, -mean_thickness/2],[0, -mean_thickness/2], [0, mean_thickness/2], [1, mean_thickness/2]];

    tip_a = acos((min(tip_chord, 0.8 * root_chord)/root_chord)^(plan_form_exponent/2));

    fillet_end = 20;
    // Compute the foil sections
    section_count = 21;
    half_spans = concat(
        [for (i = [section_count:-1:0])
            let (
                a = tip_a * i / section_count,
                s = (sin(a) / sin(tip_a)) ^ (2/plan_form_exponent),
                local_span = s * span / 2
            )
            if (local_span > fillet_end) local_span
        ],
        [for (z = [fillet_end:-1:1]) z]
    );
    spans = concat(half_spans, [0], -reverse(half_spans));

    function chord_at(local_span) =
        let (s = abs(2 * local_span / span))
        root_chord * (1 - s^plan_form_exponent * sin(tip_a)^2) ^ (1/plan_form_exponent);

    sections = [for (local_span = spans)
        let (
                s = abs(2 * local_span / span),
                c = sqrt(max(0, 1 - s*s)),
                local_chord = chord_at(local_span),
                local_twist = angle_of_attack + (1-c) * twist,
                local_droop = (1-c) * droop
            )
            path3d(wing_section(foil_surfaces, local_chord, reference_line, local_twist, local_droop), local_span)
        ];

    area = sum([for (i = [0 : len(spans) - 2])
        (spans[i] - spans[i+1]) * (chord_at(spans[i]) + chord_at(spans[i+1])) / 2]);
    aspect_ratio = span*span/area;

    echo(str("\n",
        "  shape: ", foil_name, "\n",
        "  span x root chord: ", span, "mm x ", root_chord, "mm\n",
        "  plan area: ", area/100, "cm^2\n",
        "  aspect ratio: ", aspect_ratio, "\n",
        "  mean chord: ", area/span, "mm\n",
        "  mean thickness: ", mean_thickness * area/span, "mm\n"
    ));

    module foil_text(string) {
        translate([0, -50, 0]) rotate([90, 0, 180]) linear_extrude(height=100)
            text(string, valign="center", size=text_size, font=font);
    }

    // If the angle of attack puts the trailing edge above the mount, we need to reach up to it.
    mount_web = concat(
        [for (x = [0:0.5:root_chord-0.1])
            let (s = -wing_surfaces(x, foil_surfaces, root_chord, reference_line, angle_of_attack, 0)[1])
            [x, s > 0 ? s + 0.05 : 0]],
        [[max([for (p = mount_profile) p[0]]), -0.1], [0, -0.1]]);

    module simple_tail() {
        intersection() {
            down(15) linear_extrude(height=30) union() { polygon(mount_profile); polygon(mount_web); }
            rotate([-90,0,0]) down(50) linear_extrude(height=100) polygon(mount_plan);
        }
        translate([reference_line*root_chord, 0, 0]) rotate([180,0,0]) skin(sections, slices = 0, caps = true);
    }

    difference() {
        simple_tail();

        for (hole = struct_val(MOUNT_INFO, "screw_holes")) {
            y = struct_val(hole, "location");
            size = struct_val(hole, "size");
            tail_screw_hole(y, size, foil_surfaces, foil_parameters, mount_web);
        }

        if (show_text) {
            difference() {
                union() {
                    translate([48, 0, 6])   foil_text(str(round(span), "x", round(root_chord)));
                    translate([48, 0, 2])   foil_text(str(round(area/100), " cm\u00b2"));
                    translate([48, 0, -2])  foil_text(str("AR ", round(aspect_ratio*10)/10));
                    translate([48, 0, -6])  foil_text(str("AoA ", round(angle_of_attack*100)/100, "\u00b0"));
                    translate([80, 0, 0])   foil_text(foil_name);
                }
                translate([0, -text_depth, 0]) simple_tail();
            }
        }
    }
}


//-------------------------------------------------------------------------------------------------
