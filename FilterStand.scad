// Filter stand for returning resin to bottle

bottle_max_diameter = 95;
bottle_max_height = 183;
support_rod_diameter = 9.575; // 3/8 in
support_height = 20;
wall_thickness = 4;

rim_height = 5;
base_thickness = 2;
_base_radius = bottle_max_diameter/2 + rim_height   ;
base_radius = bottle_max_diameter/2 + wall_thickness;
support_base_radius = support_rod_diameter + wall_thickness;

_rim_thickness = 3;
fillet_radius = 2;

module tray() {
    rotate_extrude(angle=360) {
        translate([_base_radius-_rim_thickness/2,rim_height-_rim_thickness/2]) circle(r=_rim_thickness/2);
        translate([_base_radius-_rim_thickness,0]) square(size=[_rim_thickness, rim_height-_rim_thickness/2]);
        square(size=[_base_radius, base_thickness]);
    }
}

module basic_base() {
        union() {
            difference() {
                hull() {
                    cylinder(r=base_radius, h=rim_height);
                    translate([0,base_radius + support_base_radius,0]) cylinder(r=support_base_radius, h=rim_height);
                }
                minkowski() {
                    translate([0,0,base_thickness+fillet_radius*2]) cylinder(r=bottle_max_diameter/2, h=rim_height);
                    sphere(r=2*fillet_radius);
                }
            }
            translate([0,base_radius + support_base_radius,0]) cylinder(r=support_base_radius, h=support_height);
        }
}

module filleted_base() {
    difference() {
        //minkowski() {
            basic_base();
            sphere(r=fillet_radius);
        //}
        //translate([0,base_radius + support_base_radius,-1]) cylinder(r=support_rod_diameter/2, h=rim_height+100);
    }
    //#tray();
}

filleted_base();