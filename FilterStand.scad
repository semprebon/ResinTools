// Filter stand for returning resin to bottle

bottle_max_diameter = 95;
bottle_max_height = 183;
support_rod_diameter = 9.575; // 3/8 in

rim_height = 5;
base_thickness = 2;
_base_radius = bottle_max_diameter/2 + rim_height   ;
_rim_thickness = 3;
fillet_radius = 2;

module tray() {
    rotate_extrude(angle=360) {
        translate([_base_radius-_rim_thickness/2,rim_height-_rim_thickness/2]) circle(r=_rim_thickness/2);
        translate([_base_radius-_rim_thickness,0]) square(size=[_rim_thickness, rim_height-_rim_thickness/2]);
        square(size=[_base_radius, base_thickness]);
    }
}

module base() {
    difference() {
        translate([-_base_radius,0,0]) cube([2*_base_radius, _base_radius + support_rod_diameter, base_thickness]);
        hull() tray();
    }
    tray();
}

base();