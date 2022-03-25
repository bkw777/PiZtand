// Vertical stand/mount for Raspberry Pi Zero, Zero 2, BanannaPi M2 Zero, Radxa Zero
// b.kenyon.w@gmail.com

// main configurables
pi_elevation = 45; // top of base to bottom edge of pcb
foot_length = 35;

// configurables
screw_post_id = 2.5; // fdm naturally shrinks holes a little, M2.5 should not need a nut
screw_post_od = 5; // 6 or less for Bannanna or Radxa, may be greater for Raspberry
beam_width = screw_post_od;
beam_thickness = beam_width;
post_offset_extra = 0; // gap between pcb and post
angle_a = 15; //30; // more post holes at other angles besides the 90 degree set
angle_b = 30; //45;
angle_c = 45; //60;
fc = 0.1; // fitment clearance - if the posts don't fit in the holes, increase this
pcr = 0.5; // post corner radius - round the corners of the post cross-section so they fit in the post holes

// not configurable - pi zero dimensions
// pcb
pcb_x = 65;
pcb_y = 30;
pcb_cr = 3;
pcb_thickness = 1.6;
// screw holes
screws_x = 58;
screws_y = 23;

post_offset_min = pcb_x/2-screws_x/2+beam_width/2; // edge of post at edge of pcb, Bananna & Radxa have parts on back
post_offset = post_offset_min + post_offset_extra; // post X offset from screw holes

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
 il = screws_x+post_offset*2-beam_width*2; // inside length
 pl = beam_thickness+pi_elevation+pcb_y/2+screws_y/2+beam_width/2; // post length
 pw = beam_width/2 + post_offset + screw_post_od/2 + s + beam_width; // posts pair width
 px = (s+pl+s>il) ? pl/2 : pl-il/2+s; // post x offset
 py = (s+pl+s>il) ? foot_length + beam_width/2 + s + pw/2 : 0; // posts pair y offset

 translate([0,-py,0]) {
  translate([-px,post_offset/2-beam_width/4-screw_post_od/4-s/2,0])
   rotate([0,0,-90])
    post();
  translate([px,-post_offset/2+beam_width/4+screw_post_od/4+s/2,0])
    rotate([0,0,90])
    post();
 }

}

module assembly (a=0) {

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

module base () {
 translate([0,0,beam_thickness/2])
  difference(){
   
   // outside
   hull()
    mirror_copy([0,1,0])
     translate([0,foot_length,0])
      mirror_copy([1,0,0])
       translate([screws_x/2+post_offset+beam_width/2,0,0])
        cylinder(h=beam_thickness,d=beam_width,center=true);

   group(){
    // inside
    hull()
     mirror_copy([0,1,0])
      translate([0,foot_length-beam_width,0])
       mirror_copy([1,0,0])
        translate([screws_x/2+post_offset-beam_width-beam_width/2,0,0])
         cylinder(h=o+beam_thickness+o,d=beam_width,center=true);

     // vertical post holes
     mirror_copy([1,0,0])
      translate([screws_x/2+post_offset,0,0])
       cube([fc+beam_width+fc,fc+beam_thickness+fc,o+beam_thickness+o],center=true);

     // angle_b post holes
      mirror_copy([1,0,0])
       translate([screws_x/2+post_offset,-foot_length/2,0])
        rotate([-angle_b,0,0])
         cube([fc+beam_width+fc,fc+beam_thickness+fc,beam_thickness*3],center=true);
      // angle_a post holes
      mirror_copy([1,0,0])
       translate([screws_x/2+post_offset,foot_length/3,0])
        rotate([angle_a,0,0])
         cube([fc+beam_width+fc,fc+beam_thickness+fc,beam_thickness*3],center=true);
      // angle_c post holes
      mirror_copy([1,0,0])
       translate([screws_x/2+post_offset,foot_length-foot_length/3,0])
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
 // arms
 translate([0,pcb_y/2+beam_thickness+pi_elevation,0]) {
  mirror_copy([0,1,0])
   translate([0,screws_y/2,0])
    arm();

  // rounded cross-section
  // mounting posts section
  hull() {
   mirror_copy([0,1,0])
    translate([post_offset,screws_y/2,0])
     cylinder(h=beam_thickness,d=beam_width);
   //translate([post_offset-beam_width/2,0,0])
   // cube([beam_width,beam_width,beam_thickness]);
  }

  // trunk - 4 small vertical cylinders hull for rounded corners
  translate([post_offset,0,beam_thickness/2])
   rotate([90,0,0])
    hull() {
     mirror_copy([0,1,0])
      translate([0,beam_thickness/2-pcr,0])
       mirror_copy([1,0,0])
        translate([beam_width/2-pcr,0,0])
         cylinder(h=beam_thickness+pi_elevation+pcb_y/2,r=pcr);
  }
 }

}

module arm () {
 difference() {
  hull () {
   cylinder(h=beam_thickness,d=screw_post_od);
   translate([post_offset,0,0])
    cylinder(h=beam_thickness,d=screw_post_od);
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
