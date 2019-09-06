// Filter stand for returning resin to bottle

bottle_max_diameter = 95;
bottle_max_height = 183;
support_rod_diameter = 9.72; // 3/8 in
support_height = 20;
wall_thickness = 4;

rim_height = 5;
base_thickness = 2;
_base_radius = bottle_max_diameter/2 + rim_height   ;
base_radius = bottle_max_diameter/2 + wall_thickness;
support_base_radius = support_rod_diameter + wall_thickness;
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
        difference() {
            hollow_cylinder(r=radius, r2=inner_radius, h=height);
            rotate([0,0,-90-10]) wedge(r=radius*2, h=height+2*fudge, angle=20);
        }
    }
}

module bevelled_support_rod_mount(radius=40, height=20, bevel=1) {
    translate([0,0,bevel]) minkowski() {
        support_rod_mount(radius=radius-bevel, inner_radius=support_rod_diameter/2+bevel, height=height-bevel);
        bevel(size=bevel);
    }
}

module basic_base() {
    union() {
        difference() {
            // basic outline
            hull() {
                rounded_cylinder(r=base_radius, h=rim_height, fillet=fillet_radius);
                translate([0,base_radius + support_base_radius,0]) {
                    rounded_cylinder(r=support_base_radius, h=rim_height, fillet=fillet_radius);
                }
            }
            // bottle well
            translate([0,0,base_thickness]) {
                rounded_cylinder(r=bottle_max_diameter/2+fillet_radius, h=rim_height, fillet=fillet_radius);
            }
        }
        translate([0,base_radius + support_base_radius,0]) support_rod_mount(h = support_height);
        // bottle well lip
        rounded_hollow_cylinder(r=base_radius, h=rim_height,r2=fillet_radius);
    }
}

module filleted_base() {
    difference() {
        basic_base();
        translate([0,base_radius + support_base_radius,-1]) cylinder(r=support_rod_diameter/2, h=rim_height+100);
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

module filter_ring(radius=48, height=10, gap_angle=60, slope=0.5, thickness=3, arm_length=10) {
    total_arm_length = arm_length + slope*height;
    rb = radius;
    rt = radius - slope*height;

    difference() {
        union() {
            // arm
            translate([-thickness/2, radius - slope*height, 0]) {
                cube([thickness, total_arm_length, height]);
            }
            cylinder(r1=rb, r2=rt, h=height);
        }
        translate([0,0,-fudge]) {
            cylinder(r1=rb-wall_thickness, r2=rt-wall_thickness, h=height+2*fudge);
        }
        // gap for drip
        rotate([0,0,-90-gap_angle/2]) wedge(r=radius*2, h=height+2*fudge, angle=10);
        //translate([-gap_width/2, -(radius), 0])
        //    cube([gap_width, radius+1,ring_height]);
    }
}

module beveled_filter_ring(radius=48, height=10, slope=48/72, arm_length=10, bevel=2) {
    translate([0,0,bevel]) minkowski() {
        filter_ring(radius=radius-bevel, height=height-bevel, slope=48/72, arm_length=arm_length-bevel);
        bevel(size=bevel);
    }
}

module filter_holder() {
    beveled_filter_ring(radius=48, height=10, slope=48/72, arm_length=10, bevel=2);
    bevelled_support_rod_mount(radius=support_base_radius, height=10, bevel=2);
}


//filleted_base();
//basic_base();
//rounded_hollow_cylinder(r=3, h=1, r2=0.2);
//filter_holder();
//filter_ring();
//beveled_filter_ring();
filter_holder();
//bevel(2);
//wedge(r=3, h=1, angle=45);