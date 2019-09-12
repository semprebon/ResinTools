spring_radius = 20;
length = 150;
width = 4;
height = 6;
gap = 0.2;
crossover_point = 40;
tip = 15;

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

module tong_half() {
    crossover_center = (crossover_point + tip_start)/2;
    crossover_height = height/2-gap;
    d1 = width / tan(max_deflection);
    d2 = width / tan(min_deflection);

    // spring
    rotate([0,0,90]) arc3d(ri=inner_radius, ro=outer_radius, h=height, angle=90);

    // arms
    difference() {
        translate([0,inner_radius,0]) cube([length,width,height]);
        linear_extrude(crossover_height) {
            polygon([[crossover_point, inner_radius], [crossover_point+d1, outer_radius], [tip_start, outer_radius], [tip_start-d2, inner_radius]]);
        }
    }
    // grasper
    grasper_width = tip * tan(min_deflection);
    linear_extrude(height) {
        polygon([[tip_start, outer_radius], [length, outer_radius], [length, outer_radius+grasper_width]]);
    }
    translate([length-width/2, outer_radius+grasper_width, width-1]) scale([width, width, height/6]) rotate([90,90,90]) linear_extrude(1, center=true) polygon([[-3,-1],[-3,1],[-1,0],[1,1],[3,0],[3,-1],[-3,-1]]);


}

module tong() {
    tong_half();
    translate([0,0,height]) mirror([0,0,1]) mirror([0,1,0]) tong_half();
}

tong();
