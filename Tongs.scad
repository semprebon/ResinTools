spring_radius = 15;
length = 120;
width = 3.2;
height = 15;
gap = 0.2;
crossover_point = 30;
tip = 15;
fudge = 0.001;

inner_radius = spring_radius-width/2;
outer_radius = spring_radius+width/2;
max_deflection = asin(inner_radius/crossover_point);
arm_length = length - outer_radius;
tip_width = length - tip;
tip_start = length-tip;
min_deflection = asin(outer_radius/tip_start);

echo(min_deflection=min_deflection, max_deflection=max_deflection);

/*
Create a 3D arc with the z axis as its center line, resting on the xy plane, starting at x=0 and
going counterclockwise when viewed from above
*/
module arc3d(ri=1, ro=2, h=1, angle=360) {
    rotate_extrude(angle=angle) translate([ri,0]) square([ro-ri, h]);
}

function grasper_profile(x, c) = x - floor(x*c)/c;

function odd(x) = (x % 2) == 1;

/*
Create the grasping end. The contact surface is along the xz plane
*/
module grasper(dim, base_height=tip*tan(min_deflection)) {
    base_dim = [dim.x, dim.y, base_height];
    //cube(base_dim);
    tooth_count = 4;
    tooth_width = dim.x / tooth_count;

    profile = [ for (x = [0 : tooth_count*2]) [x*dim.x/(tooth_count*2), odd(x) ? dim.y : 0] ];
    echo(dim=dim, tooth_width=tooth_width, profile=profile);
    linear_extrude(dim.z) polygon(concat([[0,0]],profile,[[dim.x,-base_height]])) ;
}

module position_grasper(base=true) {
    grasper_width = tip * tan(min_deflection);
    translate([length-tip, outer_radius, 0]) rotate([0,0,min_deflection]) children();
}

module tong_half() {
    crossover_center = (crossover_point + tip_start)/2;
    crossover_height = height/2-gap;
    d1 = width / tan(max_deflection);
    d2 = width / tan(min_deflection);

    // spring
    rotate([0,0,90]) arc3d(ri=inner_radius, ro=outer_radius, h=height, angle=90);

    // arms
    tip_transition = 1;
    difference() {
        translate([0,inner_radius,0]) cube([length,width,height]);
        linear_extrude(crossover_height) {
            polygon([[crossover_point, inner_radius-fudge], [crossover_point+d1, outer_radius+fudge],
                [tip_start-tip_transition, 2*outer_radius], [tip_start-tip_transition, inner_radius]]);
        }
    }
}

module tong() {
    grasper_base_width = tip*tan(min_deflection) + fudge;
    tong_half();
    position_grasper() grasper([tip, width, height]);
    translate([0,0,height]) mirror([0,0,1]) mirror([0,1,0]) {
        tong_half();
        position_grasper() {
            translate([0,width,0]) mirror([0,1,0]) difference() {
                linear_extrude(height) polygon([[0,0],[0,width],[tip, width+grasper_base_width],[tip,0]]) ;
                grasper([tip, width, height], grasper_base_width);
            }
        }
    }
}

tong();
//grasper([tip, width, height]);
