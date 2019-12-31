// Filter stand for returning resin to bottle

bottle_max_diameter = 95;
bottle_max_height = 183;
support_rod_diameter = 9.72; // 3/8 in
support_height = 20;
wall_thickness = 2.5;

rim_height = 10;
base_thickness = 2;
_base_radius = bottle_max_diameter/2 + rim_height;
base_radius = bottle_max_diameter/2 + wall_thickness;
support_base_radius = support_rod_diameter + wall_thickness;
support_rod_radius = support_rod_diameter / 2;
support_offset = base_radius + support_base_radius;

fudge = 0.001;

_rim_thickness = 3;
fillet_radius = 1.5;
$fa = 5;
$fs = 0.2;

module torus(r1=1, r2=0.5) {
    rotate_extrude() {
        translate([r1,0,0]) circle(r=r2);
    }
}

module rounded_disk(r1=1, r2=0.5) {
    hull() torus(r1=r1, r2=r2);
}

module rounded_cylinder(r=1, h=1, fillet=0.1) {
    hull() {
        translate([0,0,fillet]) rounded_disk(r1=r-fillet, r2=fillet);
        translate([0,0,h-fillet]) rounded_disk(r1=r-fillet, r2=fillet);
    }
}

module bevelled_cylinder(r=1, h=1, bevel=0.1) {
    hull() {
        translate([0,0,bevel]) cylinder(r=r, h=h-2*bevel);
        cylinder(r=r-bevel, h=h);
    }
}

module bevelled_hollow_cylinder(r=1, h=1, r2=0.5, bevel=0.1) {
    difference() {
        bevelled_cylinder(r=r, h=h, bevel=bevel);
        cylinder(r=r2, h=h+1);
        cylinder(r1=r2+bevel, r2=r2, h=bevel);
        translate([0,0,h]) mirror([0,0,1]) cylinder(r1=r2+bevel, r2=r2, h=bevel);
    }
}

module hollow_cylinder(r=1, h=1, r2=0.5) {
    difference() {
        cylinder(r=r, h=h);
        cylinder(r=r2, h=h);
    }
}

module rounded_hollow_cylinder(r=1, h=1, r2=0.1) {
    translate([0,0,r2]) torus(r1=r-r2, r2=r2);
    translate([0,0,r2]) hollow_cylinder(r=r, h=h-2*r2, r2=r-r2);
    translate([0,0,h-r2]) torus(r1=r-r2, r2=r2);
}

module support_rod_mount2(h = 1.0) {
    bevel = 1;
    difference() {
        rounded_cylinder(r=support_base_radius, h=h, fillet=fillet_radius);
        union() {
            cylinder(r=support_rod_diameter/2, h=h);
            translate([0,0,support_height-bevel]) {
                cylinder(r1=support_rod_diameter/2, r2=support_rod_diameter/2+bevel, h=bevel+fudge);
            }
        }
    }
}

module support_rod_mount(radius=40, height=20, inner_radius=10) {
    translate([0, support_offset,0]) {
        hollow_cylinder(r=radius, r2=inner_radius, h=height);
    }
}

module bevelled_support_rod_mount(radius=40, height=20, bevel=1, inner_radius=10) {
    translate([0,0,bevel]) minkowski() {
        support_rod_mount(radius=radius-bevel, inner_radius=support_rod_radius+bevel, height=height-bevel);
        bevel(size=bevel);
    }
}

module basic_base() {
    bevel = wall_thickness/4;
    union() {
        difference() {
            // basic outline
            hull() {
                //rounded_cylinder(r=base_radius, h=rim_height, fillet=fillet_radius);
                bevelled_cylinder(r=base_radius, h=rim_height, bevel=bevel);
                translate([0,base_radius + support_base_radius,0]) {
                    bevelled_cylinder(r=support_base_radius, h=rim_height, bevel=bevel);
                }
            }
            // bottle well
            translate([0,0,base_thickness]) {
                bevelled_cylinder(r=bottle_max_diameter/2, h=rim_height, bevel=bevel);
            }
            translate([0,0,base_thickness+bevel]) cylinder(r=bottle_max_diameter/2+bevel, h=rim_height);
            // rod hole
            translate([0,support_offset,base_thickness]) cylinder(r=support_rod_radius, h=rim_height*2);
        }
        bevelled_support_rod_mount(radius=support_base_radius, height=support_height, inner_radius=support_rod_radius);
        // bottle well lip
        bevelled_hollow_cylinder(r=base_radius, h=rim_height, r2=bottle_max_diameter/2, bevel=bevel);
    }
}

module bevelled_base() {
    basic_base();
}

module filleted_base() {
    difference() {
        basic_base();
        translate([0,base_radius + support_base_radius,base_thickness]) cylinder(r=support_rod_diameter/2, h=rim_height+100);
    }
    //#tray();
}

module bevel(size=1.0) {
    side = size * sqrt(2);
    linear_extrude(height=size, scale=0) square(size=side, center=true);
    mirror([0,0,1]) linear_extrude(height=size, scale=0) square(size=side, center=true);
}

module wedge(r=2, h=1, angle=60) {
    rotate_extrude(angle=angle) square([r,h]);
}

module filter_ring(radius=48, height=25, arm_height=10, gap_angle=60, slope=0.5, thickness=2, arm_length=10) {
    total_arm_length = arm_length + slope*height;
    rb = radius;
    rt = radius - slope*height;

    difference() {
        union() {
            // arm
            translate([-thickness/2, radius - slope*height, 0]) {
                cube([thickness, total_arm_length, arm_height]);
            }
            cylinder(r1=rb, r2=rt, h=height);
        }
        translate([0,0,-fudge]) {
            cylinder(r1=rb-thickness, r2=rt-thickness, h=height+2*fudge);
        }
        // drip gap
        if (gap_angle > 0) {
            rotate([0,0,-90-gap_angle/2]) wedge(r=radius*2, h=height+2*fudge, angle=gap_angle);
        }
    }
}

module beveled_filter_ring(radius=48, height=25, arm_height=10, slope=48/72, arm_length=10, bevel=2) {
//    translate([0,0,bevel]) minkowski() {
        filter_ring(radius=radius-bevel, height=height-bevel, arm_height=arm_height-bevel, slope=48/72,
            arm_length=arm_length, gap_angle=0);
//        bevel(size=bevel);
//    }
}

module filter_holder(radius=48, height=25, bevel=0.5) {
    arm_height = 10;
    slope = 2/3;
    arm_length = support_offset - radius - support_rod_radius;
    bolt_flange_length = 10;
    gap_width=2;
    bolt_flange_thickness = 3;
    separation = 2*bolt_flange_thickness + gap_width;
    bolt_radius = 3.4/2;

    echo(radius=radius, height=height, arm_height=arm_height, slope=slope, arm_length=arm_length, bevel=bevel);
    beveled_filter_ring(radius=radius, height=height, arm_height=arm_height, slope=slope, arm_length=arm_length, bevel=bevel);
    difference() {
        union() {
            bevelled_support_rod_mount(radius=support_rod_radius+bolt_flange_thickness, height=arm_height, bevel=bevel);
            minkowski() {
                translate([-separation/2+bevel,support_offset+support_rod_radius+bevel,bevel]) {
                    cube([separation-bevel*2, bolt_flange_length, arm_height-bevel]);
                }
                bevel(size=bevel);
            }
        }
        // thightening gap
        translate([-gap_width/2,support_offset,-1]) cube([gap_width, radius*2, height*2]);

        // bolt hole
        translate([0,support_offset+support_rod_radius+bevel+bolt_flange_length-2.5*bolt_radius,arm_height/2]) {
            rotate([0,90,0]) cylinder(r=bolt_radius, h=40, center=true);
        }
    }
}


//filleted_base();
//basic_base();
//bevelled_hollow_cylinder(r=3, h=1, r2=1, bevel=0.1);
//filter_holder();
//filter_ring();
filter_holder(radius = 57, height = 32, bevel = 0.5);
//filter_holder(height=25);
//bevel(2);
//wedge(r=3, h=1, angle=45);