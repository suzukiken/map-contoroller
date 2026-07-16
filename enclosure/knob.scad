// RKJXT1F42001 ロータリーエンコーダー用ノブ
// データシート: 内側金属シャフト Ø2.5 mm（D カット）
//
// OpenSCAD で F6 → F7 で STL 出力

// --- シャフト（RKJXT1F42001 内側シャフト） ---
shaft_d = 2.5;
shaft_flat_w = 2.0;      // D カット側の幅（フラット面）
shaft_bore_clearance = 0.4;
shaft_engagement = 6.0;  // シャフト突出 ~6.6 mm

// --- ノブ外形 ---
knob_d = 14.0;
knob_h = 12.0;
top_fillet_r = 1.5;

module d_shaft_bore(height) {
    bore_d = shaft_d + shaft_bore_clearance;
    difference() {
        cylinder(d = bore_d, h = height, center = true, $fn = 64);
        // D 型フラット（+X 側を削る）
        translate([1.2, 0, 0]) {
            cube([1.2, 3, height + 0.2], center = true);
        }
    }
}

module encoder_knob() {
    difference() {
        union() {
            cylinder(d = knob_d, h = knob_h, center = true, $fn = 80);
            // 上面を少し丸める
            translate([0, 0, knob_h / 2 - top_fillet_r]) {
                rotate_extrude($fn = 80) {
                    translate([knob_d / 2 - top_fillet_r, 0, 0]) {
                        circle(r = top_fillet_r, $fn = 32);
                    }
                }
            }
        }

        translate([0, 0, knob_h / 2 - shaft_engagement / 2]) {
            d_shaft_bore(shaft_engagement + 0.4);
        }
    }
}

encoder_knob();
