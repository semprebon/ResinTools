spring_radius = 20;
length = 150;
width = 4;
height = 6;
gap = 0.2;
crossover_point = 30;
tip = 15;

inner_radius = spring_radius-width/2;
outer_radius = spring_radius+width/2;
max_deflection = asin(inner_radius/crossover_point);
arm_length = length - outer_radius;
tip_width = length - tip;
tip_start = length-tip;
min_deflection = asin(outer_radius/tip_start);

echo(min_deflection=min_deflection, max_deflection=max_deflection);

/* Create a 3D arc with the z axis as its center line, resting on the xy plane, starting at x=0 and
    going counterclockwise when viewed from above */
module arc3d(ri=1, ro=2, h=1, angle=360) {
    rotate_extrude(angle=angle) translate([ri,0]) square([ro-ri, h]);
}

module tong_half() {
    crossover_center = (crossover_point + tip_start)/2;
    crossover_height = height/2-gap;

    rotate([0,0,90]) arc3d(ri=inner_radius, ro=outer_radius, h=height, angle=90);
    difference() {
        translate([0,inner_radius,0]) cube([length,width,height]);
        translate([crossover_center, inner_radius, crossover_height/2]) rotate([0,0,-max_deflection]) {
            cube([crossover_point-tip, length, crossover_height], center=true);
        }
    }

}

module tong() {
    tong_half();
    translate([0,0,height]) mirror([0,0,1]) mirror([0,1,0]) tong_half();
}

tong();
