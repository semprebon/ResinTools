inner_radius = 70;
wall_thickness = 1.5;
outer_radius = inner_radius + wall_thickness;
inner_height = 120;
outer_height = inner_height + wall_thickness;
$fa = 5;
$fs = 0.2;

module cylindrical_box(r=10, h=6, thickness=1) {
    difference() {
        cylinder(r=r, h=h);
        translate([0,0,wall_thickness]) cylinder(r=r-thickness, h=h-thickness);
    }
}

module base() {
    base_radius = outer_radius+2*wall_thickness;

    cylinder(r=base_radius, h=wall_thickness);
    cylindrical_box(r=outer_radius+wall_thickness, h=wall_thickness*2, thickness=wall_thickness);
}

//cylindrical_box(r=outer_radius, h=outer_height, thickness=wall_thickness);

base();

