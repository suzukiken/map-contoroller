#include QMK_KEYBOARD_H

// RKJXT1F42001 は方向を倒すと Push 端子も同時に ON になる（データシート仕様）。
// raw_matrix を書き換えると sym_defer_g デバウンスが完了せず方向キー全体が効かなくなるため、
// Enter 送信時だけ GPIO を見て Push を捨てる。
static bool any_direction_pressed(void) {
    return !gpio_read_pin(GP6) || !gpio_read_pin(GP27) || !gpio_read_pin(GP28) || !gpio_read_pin(GP0);
}

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    if (record->event.key.col == 4 && any_direction_pressed()) {
        return false;
    }
    return true;
}
