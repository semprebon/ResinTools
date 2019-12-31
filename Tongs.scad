spring_radius = 15;
length = 120;
width = 3.6;
height = 15;
gap = 0.2;
crossover_point = 30;
tip = 15;
tip_offset = 15;
fudge = 0.001;

inner_radius = spring_radius-width/2;
outer_radius = spring_radius+width/2;
max_deflection = asin(inner_radius/crossover_point);
arm_length = length - outer_radius;
tip_width = length - tip;
tip_start = length-tip;
min_deflection = asin(outer_radius/(tip_start-tip_offset));

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

function range_for(a) = [0:(len(a)-1)];

function quot(a, b) = [ for(i = [0:(len(a)-1)]) a[i] / b[i] ];
function prod(a, b) = [ for(i = [0:(len(a)-1)]) a[i] * b[i] ];

/*
Create the grasping end. The contact surface is along the xz plane
*/
module grasper(dim, base_height=tip*tan(min_deflection)) {
    base_dim = [dim.x, dim.y, base_height];
    //cube(base_dim);
    tooth_count = 2;
    tooth_width = dim.x / tooth_count;

    profile = [ for (x = [0 : tooth_count*2]) [x*dim.x/(tooth_count*2), odd(x) ? dim.y : 0] ];
    echo(dim=dim, tooth_width=tooth_width, profile=profile);
    linear_extrude(dim.z) polygon(concat([[0,0]],profile,[[dim.x,-base_height]])) ;
}

module mesh() {
    difference() {
        children();
        mirror([0,1,0]) {
            children(1);
        }
    }
}

function offset(base, dim, pos) = offset + prod(dim, pos);
/*
Create the grasping end. The contact surface is along the xz plane
*/
module spike_grasper(dim, base_width=tip*tan(min_deflection), tip_offset=tip_offset) {
    //cube(base_dim);
    tip_dim = dim - [tip_offset, 0, 0];
    tooth_count = 2;
    tooth_width = dim.x / tooth_count;
//    profile = [ for (x = [0 : tooth_count*2]) [x*dim.x/(tooth_count*2), odd(x) ? dim.y : 0] ];
//   echo(dim=dim, tooth_width=tooth_width, profile=profile);
//    linear_extrude(dim.z) polygon(concat([[0,0]],profile,[[dim.x,-base_height]])) ;
//    linear_extrude(height) polygon([[0,0],[0,width],[tip, width+base_width],[tip,0]]) ;

    tooth_counts = [3,-1000,2];
    echo(dim=dim, tip_dim=tip_dim);
    tooth_dim = quot(tip_dim, tooth_counts);
    cell_offset = [tip_offset, 0, 0];
    tooth_offset = (tooth_dim / 2) + cell_offset;
    r = min(tooth_dim.x, tooth_dim.z)/2;
    tooth_height = r*1.7;
    echo(tooth_counts=tooth_counts, tooth_dim=tooth_dim, tooth_offset=tooth_offset, r=r);
    for (x = [0:2]) {
        for (z = [0:1]) {
            echo(x=x, z=z, p=tooth_offset + prod([x,0,z], tooth_dim));
            if (odd(z*tooth_counts.x+x)) {
                translate(tooth_offset + prod([x,0,z], tooth_dim)) rotate([ odd(z*tooth_counts.x+x)?-90:+90,0,0]) cylinder(r1=r, r2=0, h=tooth_height);
                translate([0,-base_width,0]) translate(prod([x,0,z], tooth_dim) + cell_offset) cube([tooth_dim.x, base_width, tooth_dim.z]);
            } else {
                difference() {
                    translate([0,-base_width,0]) translate(prod([x,0,z], tooth_dim) + cell_offset) cube([tooth_dim.x, base_width, tooth_dim.z]);
                    translate([0,0.1,0]) translate(tooth_offset + prod([x,0,z], tooth_dim)) rotate([ odd(z*tooth_counts.x+x)?-90:+90,0,0]) cylinder(r1=r, r2=0, h=tooth_height);
                }
          }
        }
    }
}

module tip(dim, base_width=tip*tan(min_deflection), tip_offset=tip_offset) {
    grasper_offset = tip_offset * sin(min_deflection) + width / cos(min_deflection) - base_width;
    echo(grasper_offset=grasper_offset);
    translate([0,-dim.y,0]) cube([dim.x, grasper_offset+0.75, dim.z]);
    translate([0,grasper_offset,0]) spike_grasper(dim, base_width, 0);
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
        translate([0,inner_radius,0]) cube([tip_start+1,width,height]);
        linear_extrude(crossover_height) {
            polygon([[crossover_point, inner_radius-fudge], [crossover_point+d1, outer_radius+fudge],
                [tip_start-tip_transition, 2*outer_radius], [tip_start-tip_transition, inner_radius]]);
        }
    }
}

module tong() {
    grasper_base_width = tip*tan(min_deflection) + fudge;
    tong_half();
    position_grasper() tip([tip, width, height]);
    translate([0,0,height]) mirror([0,0,1]) mirror([0,1,0]) {
        tong_half();
        position_grasper() {
            tip([tip, width, height], grasper_base_width);
//            translate([0,width,0]) mirror([0,1,0]) difference() {
//                linear_extrude(height) polygon([[0,0],[0,width],[tip, width+grasper_base_width],[tip,0]]) ;
//                spike_grasper([tip, width, height], grasper_base_width);
//            }
        }
    }
}

tong();
//spike_grasper([tip, width, height]);
