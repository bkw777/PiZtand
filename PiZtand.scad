// Vertical stand/mount for Raspberry Pi Zero, Zero 2, BanannaPi M2 Zero, Radxa Zero
// b.kenyon.w@gmail.com

// TODOS
// * cable holder
// * wifi antenna holder
// * anchor points for weighted feet or plate
// * connect to breadboard
// * horizontal flat option (no uprights)

// main configurables
pi_elevation = 45; // top of base to bottom of pcb - can be as little as 0, but if this is too short, you won't have room for a normal usb power plug. At 20-40 you'll need a 90 degree usb plug. At 0 you'll need to power by the gpio pins.
foot_length = 35; // base center post to front or rear

// configurables
screw_post_id = 2.5; // fdm naturally shrinks holes a little, M2.5 should not need a nut
screw_post_od = 5; // 6 or less for Bannanna or Radxa, may be greater for Raspberry
style = "thin"; // thin or chunky
beam_width = (style=="chunky") ? screw_post_od : 2;
beam_thickness = (style=="chunky") ? beam_width : 6;
post_offset = 0; // gap between pcb and post
// there is always one set of vertical post holes in the center of the base
// these are 3 optional extra sets of post holes at various angles off from vertical
// 0 means don't include that set of holes
angle_a = 15; // 0 15 30
angle_b = 30; // 0 30 45
angle_c = 45; // 0 45 60
fc = 0.1; // fitment clearance - if the posts don't fit in the holes, increase this by 0.05 or 0.1
pcr = 0.75; // post corner radius - holes can never have perfectly sharp inside corners, posts need the corners slightly rounded to fit in the holes

// not configurable - pi zero dimensions
// pcb
pcb_x = 65;
pcb_y = 30;
pcb_cr = 3;
pcb_thickness = 1.6;
// screw holes
screws_x = 58;
screws_y = 23;

arm_length_min = pcb_x/2-screws_x/2+beam_width/2; // edge of post at edge of pcb, Bananna & Radxa have parts on back
arm_length = arm_length_min + post_offset; // screw center to beam center

$fn = 36;
o = 0.01;
s=1; // print_kit() part seperation

print_kit();  // print all parts
//base(); // print just the base
//post(); // print just one post

//assembly(); // display all parts assembled
//assembly(angle_a);
translate([0,0,beam_thickness*4]) %assembly(angle_b);
//assembly(angle_c);

module print_kit () {

 base();

 // automatically put posts in the middle if they fit, else in front
 il = screws_x+arm_length*2-beam_width*2; // inside length
 pl = beam_thickness+pi_elevation+pcb_y/2+screws_y/2+screw_post_od/2; // post length
 pw = beam_width/2 + arm_length + screw_post_od/2 + s + beam_width; // posts pair width
 px = (s+pl+s>il) ? pl/2 : pl-il/2+s; // post x offset
 py = (s+pl+s>il) ? foot_length + beam_width/2 + s + pw/2 : 0; // posts pair y offset

 translate([0,-py,0]) {
  translate([-px,arm_length/2-beam_width/4-screw_post_od/4-s/2,0])
   rotate([0,0,-90])
    post();
  translate([px,-arm_length/2+beam_width/4+screw_post_od/4+s/2,0])
    rotate([0,0,90])
    post();
 }

}

module assembly (a=0) {

 if (angle_a>0 && a==angle_a)
  translate([0,foot_length/3,beam_thickness/2])
   rotate([-a,0,180])
    translate([0,0,-beam_thickness/3])
     tower();

 else if(angle_b>0 && a==angle_b)
  translate([0,-foot_length/2,beam_thickness/2])
   rotate([-a,0,0])
    translate([0,0,-beam_thickness/4])
     tower();

 else if(angle_c>0 && a==angle_c)
  translate([0,foot_length-foot_length/3,beam_thickness/2])
   rotate([-a,0,180])
    translate([0,0,-beam_thickness/5])
     tower();

 else tower();

 base();
}

module base () {
 translate([0,0,beam_thickness/2])
  difference(){
   
   // outside
   hull()
    mirror_copy([0,1,0])
     translate([0,foot_length,0])
      mirror_copy([1,0,0])
       translate([screws_x/2+arm_length+beam_width/2,0,0])
        cylinder(h=beam_thickness,d=beam_width,center=true);

   group(){
    // cut out middle
    hull()
     mirror_copy([0,1,0])
      translate([0,foot_length-beam_width,0])
       mirror_copy([1,0,0])
        translate([screws_x/2+arm_length-beam_width-beam_width/2,0,0])
         cylinder(h=o+beam_thickness+o,d=beam_width,center=true);

    // vertical post holes
    mirror_copy([1,0,0])
     translate([screws_x/2+arm_length,0,0])
      cube([fc+beam_width+fc,fc+beam_thickness+fc,o+beam_thickness+o],center=true);

    // angle_a post holes
    if(angle_a>0)
     mirror_copy([1,0,0])
      translate([screws_x/2+arm_length,foot_length/3,0])
       rotate([angle_a,0,0])
        cube([fc+beam_width+fc,fc+beam_thickness+fc,beam_thickness*3],center=true);
    // angle_b post holes
    if(angle_b>0)
     mirror_copy([1,0,0])
      translate([screws_x/2+arm_length,-foot_length/2,0])
       rotate([-angle_b,0,0])
        cube([fc+beam_width+fc,fc+beam_thickness+fc,beam_thickness*3],center=true);
    // angle_c post holes
    if(angle_c>0)
     mirror_copy([1,0,0])
      translate([screws_x/2+arm_length,foot_length-foot_length/3,0])
       rotate([angle_c,0,0])
        cube([fc+beam_width+fc,fc+beam_thickness+fc,beam_thickness*3],center=true);
   } // group

  } // difference
}

module tower () {
  translate([0,-beam_thickness/2,beam_thickness+pi_elevation+pcb_y/2])
   rotate([90,0,0])
    %pcb();

  translate([0,beam_thickness/2,0])
   rotate([90,0,0])
    mirror_copy([1,0,0])
     translate([screws_x/2,0,0])
      post();
}

module post () {
 translate([0,pcb_y/2+beam_thickness+pi_elevation,0]) {

  // arms
  mirror_copy([0,1,0])
   translate([0,screws_y/2,0])
    arm();

  // trunk - rounded corners for tighter fit in post hole
  translate([arm_length,screws_y/2+screw_post_od/2,beam_thickness/2])
   rotate([90,0,0])
    hull()
     mirror_copy([0,1,0])
      translate([0,beam_thickness/2-pcr,0])
       mirror_copy([1,0,0])
        translate([beam_width/2-pcr,0,0])
         cylinder(h=beam_thickness+pi_elevation+pcb_y/2+screws_y/2+screw_post_od/2,r=pcr);

 }
}

module arm () {
 difference() {

  hull () {
   cylinder(h=beam_thickness,d=screw_post_od);
   translate([arm_length-1,-screw_post_od/2,0])
    cube([1,screw_post_od,beam_thickness]);
  }

  translate([0,0,-o])
   cylinder(h=o+beam_thickness+o,d=screw_post_id);

 }
}

module pcb() {
 difference() {
  hull() {
   mirror_copy([0,1,0])
    translate([0,pcb_y/2-pcb_cr,0])
     mirror_copy([1,0,0])
      translate([pcb_x/2-pcb_cr,0,0])
       cylinder(h=pcb_thickness,r=pcb_cr);
  }
 mirror_copy([0,1,0])
  translate([0,screws_y/2,0])
   mirror_copy([1,0,0])
    translate([screws_x/2,0,-o])
     cylinder(h=o+pcb_thickness+o,d=screw_post_id);
 }

}

module mirror_copy(v) {
 children();
 mirror(v) children();
}
