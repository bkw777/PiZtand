// Vertical stand/mount for Raspberry Pi Zero, Zero 2, BananaPi M2 Zero, Radxa Zero
// b.kenyon.w@gmail.com

// TODOS
// * cable holder (clip on)
// * wifi antenna holder (clip on)
// * anchor points for weighted feet or plate
// * attach to breadboard
// * horizontal mount option (no uprights)
// * snap-together screwless option

// Some comments structured to please the Thingiverse Customizer

print_kit();  // print all parts
//base(); // print just the base
//post(); // print just one post

// ---- main configurables ----

// thin or chunky
style = "thin";
// Top surface of base to bottom of PCB. Can be as little as 0, but if this is too short, you won't have room for a normal usb power plug. Below 40 and you'll need a 90-degree usb cable. Below 15 and you'll need to power the Pi through the gpio pins instead of usb.
pi_elevation = 45; // 45
// How much "foot" from the tower to the front or rear of the base. (how big to make the base from front to back)
foot_length = 35; // 35
// ---- other configurables ----

// Screw hole I.D. (variable is "screw_id" but thingiverse customizer doesn't show it?) The screws are M2.5, and FDM shrinks holes a little, so setting this to 2.5 usually results in a hole that is actually slightly less, and a M2.5 screw screws into the plastic perfectly. If the hole comes our too loose to hold a screw, try just reducing this to 2.4
screw_id = 2.5;
// Width of the screw mount arm coming from the tower to the screw hole. May not exceed 6mm for Banana or Radxa boards, as there are components on the back. This is also used for the beam_width and beam_thickness for the "chunky" version.
screw_od = 5;

// blargh, needless extra code just to work around Thingiverse customizer
// It doesn't understand the conditional assignment syntax for beam_width & beam_thickness, and doesn't even show the variable to the user at all.
// So this is just a kludgey way to get the values exposed where the user can see them and change them.

// size of beams for "thin" version
thin_beam_width = 2;
thin_beam_thickness = 6;
// size of beams for "chunky" version
chunky_beam_width = screw_od;
chunky_beam_thickness = chunky_beam_width;

beam_width = (style=="chunky") ? chunky_beam_width : thin_beam_width;
beam_thickness = (style=="chunky") ? chunky_beam_thickness : thin_beam_thickness;

// Gap between the edge of the pcb and the post. The post comes no closer than the edge of the pcb, because the Banana and Radxa boards have components on the back. But you can increase this to make a wider base & tower if you want.
post_offset = 0;

// There is always one set of post holes that are not optional, always in the center of the base, always perfectly vertical. In addition to that, there are optionally 3 more sets of post holes at different angles and positions. Setting any of these to 0 will disable that set of extra post holes.
angle_a = 15; // 0 15 30
angle_b = 30; // 0 30 45
angle_c = 45; // 0 45 60

// fitment clearance - if the posts don't fit in the holes, increase this by 0.05 or 0.1
fc = 0.1; 

// post corner radius - holes can never have perfectly sharp inside corners, posts need the corners slightly rounded to fit in the holes
pcr = 0.75; 

// Seperation between parts in print_kit(). 1 is fine.
s=1;

// These are reference, not configurable.
// The "+ 0" is just a hack to hide the variable from Thingiverse customizer.
// pcb dimensions
pcb_x = 65 + 0;
pcb_y = 30 + 0;
pcb_cr = 3 + 0;
pcb_thickness = 1.6 + 0;
screws_x = 58 + 0;
screws_y = 23 + 0;

arm_length_min = pcb_x/2-screws_x/2+beam_width/2; // edge of post at edge of pcb, Banana & Radxa have parts on back
arm_length = arm_length_min + post_offset; // screw center to beam center

// arc smoothness
$fn = 36;
// cut/join overlap
o = 0.01 + 0;


dx = pcb_x + post_offset*2 + beam_width*2 + 20;
dy = foot_length*2 + beam_width + 20;
translate([-dx*1.5,dy,0]) %assembly();
translate([-dx*0.5,dy,0]) rotate([0,0,180]) %assembly(angle_a);
translate([dx*0.5,dy,0]) %assembly(angle_b);
translate([dx*1.5,dy,0]) rotate([0,0,180]) %assembly(angle_c);

module print_kit () {

 base();

 // automatically put posts in the middle if they fit, else in front
 il = screws_x+arm_length*2-beam_width*2; // inside length
 pl = beam_thickness+pi_elevation+pcb_y/2+screws_y/2+screw_od/2; // post length
 pw = beam_width/2 + arm_length + screw_od/2 + s + beam_width; // posts pair width
 px = (s+pl+s>il) ? pl/2 : pl-il/2+s; // post x offset
 py = (s+pl+s>il) ? foot_length + beam_width/2 + s + pw/2 : 0; // posts pair y offset

 translate([0,-py,0]) {
  translate([-px,arm_length/2-beam_width/4-screw_od/4-s/2,0])
   rotate([0,0,-90])
    post();
  translate([px,-arm_length/2+beam_width/4+screw_od/4+s/2,0])
    rotate([0,0,90])
    post();
 }

}

module assembly (a=90) {
 if (a>0) {

 if (a==angle_a)
  translate([0,foot_length/3,beam_thickness/2])
   rotate([-a,0,180])
    translate([0,0,-beam_thickness/3])
     tower();

 else if(a==angle_b)
  translate([0,-foot_length/2,beam_thickness/2])
   rotate([-a,0,0])
    translate([0,0,-beam_thickness/4])
     tower();

 else if(a==angle_c)
  translate([0,foot_length-foot_length/3,beam_thickness/2])
   rotate([-a,0,180])
    translate([0,0,-beam_thickness/5])
     tower();

 else tower();

 base();
 }
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
  translate([arm_length,screws_y/2+screw_od/2,beam_thickness/2])
   rotate([90,0,0])
    hull()
     mirror_copy([0,1,0])
      translate([0,beam_thickness/2-pcr,0])
       mirror_copy([1,0,0])
        translate([beam_width/2-pcr,0,0])
         cylinder(h=beam_thickness+pi_elevation+pcb_y/2+screws_y/2+screw_od/2,r=pcr);

 }
}

module arm () {
 difference() {

  hull () {
   cylinder(h=beam_thickness,d=screw_od);
   translate([arm_length-1,-screw_od/2,0])
    cube([1,screw_od,beam_thickness]);
  }

  translate([0,0,-o])
   cylinder(h=o+beam_thickness+o,d=screw_id);

 }
}

module pcb() {
 color("green",0.1)
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
     cylinder(h=o+pcb_thickness+o,d=screw_id);
 }

}

module mirror_copy(v) {
 children();
 mirror(v) children();
}
