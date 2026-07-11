padding = 1.6; // wall width
// a little space for inserting PCB, 0.5 is good for PETG
// 0.3 is good for PLA with 0.6 nozzle
board_margin = 0.3;
side_padding = padding + board_margin;
board_2_fook_margin = 0.3;
// board_depth = 1.6; // 0.8 or 1.6
board_under_space = 1.6;
board_corner_radius = 1.5;
fook_height = 0.6;
fook_length = 5;
fook_width = 1.0;
pico_width = 21;
pico_offset = 2;
screw_radius = 1.1;
screw_pillor_radius = 3.31;
pico_pillor_radius = 2.2;
screw_pillor_offset = 2.0;
screw_head_height = 1.7;
screw_head_radius = 2.3;
screw_head_margin = 0.3;
outer_corner_radius = board_corner_radius + side_padding;

// base bucket
module outer_bucket(board_w, board_h, depth) {
    minkowski()
    {
        cylinder_height = 1;
        cube([
            board_w + side_padding * 2 - outer_corner_radius * 2, 
            board_h + side_padding * 2 - outer_corner_radius * 2, 
            cylinder_height
        ], center=true);
        cylinder(
            r=outer_corner_radius,
            h=depth - cylinder_height, 
            center=true,
            $fn=50
        );
    }
}
// hole for board
module board_hole(board_w, board_h, depth) {
    minkowski()
    {
        cylinder_height = 1;
        cube([
            board_w + board_margin * 2 - (board_corner_radius + board_margin) * 2, 
            board_h + board_margin * 2 - (board_corner_radius + board_margin) * 2, 
            cylinder_height
        ], center=true);
        cylinder(
            r=board_corner_radius + board_margin,
            h=depth - cylinder_height - padding, 
            center=true,
            $fn=50
        );
    }
}

// hole for usb
module usb_hole() {
    cube([12, 12, 2], center=true); // usb hole
}

module screw_pillar(depth, withcube) {
    translate([0, 0, - (depth - padding) / 2 + board_under_space]) {
        cylinder(r=screw_pillor_radius, h=board_under_space, center=true, $fn=30);
    }
    if (withcube) {
        translate([- screw_pillor_radius + padding, padding + 0.04, - (depth - padding) / 2 + board_under_space]) {
            cube([screw_pillor_radius, screw_pillor_radius, board_under_space], center=true);
        }
        translate([padding + 0.04, - screw_pillor_radius + padding, - (depth - padding) / 2 + board_under_space]) {
            cube([screw_pillor_radius, screw_pillor_radius, board_under_space], center=true);
        }
    }
}

module screw_hole(depth) {
    hole_height = padding + board_under_space;
    translate([0, 0, - (depth - hole_height) / 2]) {
        cylinder(r=screw_radius, h=hole_height, center=true, $fn=20);
    }
    translate([0, 0, - (depth - screw_head_height) / 2 + screw_head_margin]) {
        #cylinder(r1=screw_head_radius, r2=screw_radius, h=screw_head_height, center=true, $fn=20);
    }
    translate([0, 0, - (depth - screw_head_margin) / 2]) {
        cylinder(r=screw_head_radius, h=screw_head_margin, center=true, $fn=20);
    }
    translate([0, 0, (depth - fook_height) / 2]) {
        rotate([0, 0, 0]) {
            cube([8, 8, fook_height], center=true, $fn=20);
        }
    }
}



module main(board_w, board_h, board_d) {
    depth = fook_height + board_d + board_2_fook_margin + board_under_space + padding;
    difference() {
        union() {
            difference() {
                outer_bucket(board_w, board_h, depth);
                translate([0, 0, padding / 2 + 0.01]) {
                    board_hole(board_w, board_h, depth);
                }
                // usb hole
                translate([
                    - board_w / 2, 
                    board_h / 2 - pico_width / 2, 
                    depth / 2
                ]) {
                    usb_hole();
                }
            }
            // center pillor under pico
            translate([
                - board_w / 2 + screw_pillor_offset + 1, 
                board_h / 2 - pico_width / 2, 
                - (depth - padding) / 2 + board_under_space
            ]) {
                cylinder(r=pico_pillor_radius, h=board_under_space, center=true, $fn=30);
            }

            // fooks
            translate([
                - (board_w - fook_length) / 2 - board_margin, 
                - (board_h - fook_width) / 2 - board_margin, 
                (depth - fook_height) / 2
                ]) {
                cube([fook_length, fook_width, fook_height], center=true);
            }
            
            translate([
                - (board_w - fook_length) / 2 - board_margin, 
                (board_h - fook_width) / 2 + board_margin, 
                (depth - fook_height) / 2
                ]) {
                cube([fook_length, fook_width, fook_height], center=true);
            }
            // screw_pillar
            translate([board_w / 2 - screw_pillor_offset, board_h / 2 - screw_pillor_offset, 0]) {
                rotate([0, 0, 180]) {
                    screw_pillar(depth, true);
                }
            }
            
            translate([board_w / 2 - screw_pillor_offset, - board_h / 2 + screw_pillor_offset, 0]) {
                rotate([0, 0, 90]) {
                    screw_pillar(depth, true);
                }
            }

        }

        translate([board_w / 2 - screw_pillor_offset, board_h / 2 - screw_pillor_offset, 0]) {
            rotate([0, 0, 90]) {
                screw_hole(depth);
            }
        }
        translate([board_w / 2 - screw_pillor_offset, - board_h / 2 + screw_pillor_offset, 0]) {
            rotate([0, 0, 0]) {
                screw_hole(depth);
            }
        }

    }
}

main(45, 21, 1.6);
