// 地図アプリ(android/MyCarNavi)用コントローラーのキーマップ。
// MainActivity.dispatchKeyEvent() が受けるキーコードに合わせている:
//   矢印キー   -> 地図スクロール
//   PgUp/PgDn  -> ズームイン/アウト (エンコーダ回転)
//   Enter      -> 画面中心を目的地にセット
//   Space      -> 現在地へ移動
//   V          -> 音声入力で目的地検索
//   P          -> 駐車場の表示切り替え
#include QMK_KEYBOARD_H

enum tap_dance_ids {
    TD_PUSH,
};

typedef enum {
    TD_STATE_NONE,
    TD_STATE_SINGLE_TAP,
    TD_STATE_SINGLE_HOLD,
    TD_STATE_DOUBLE_TAP,
    TD_STATE_TRIPLE_TAP,
} td_state_t;

static td_state_t td_push_state = TD_STATE_NONE;

static td_state_t current_dance_state(tap_dance_state_t *state) {
    if (state->count == 1) {
        return (state->pressed) ? TD_STATE_SINGLE_HOLD : TD_STATE_SINGLE_TAP;
    }
    if (state->count == 2) {
        return TD_STATE_DOUBLE_TAP;
    }
    if (state->count == 3) {
        return TD_STATE_TRIPLE_TAP;
    }
    return TD_STATE_NONE;
}

static void td_push_finished(tap_dance_state_t *state, void *user_data) {
    td_push_state = current_dance_state(state);
    switch (td_push_state) {
        case TD_STATE_SINGLE_TAP:  register_code(KC_ENT); break; // 目的地セット
        case TD_STATE_SINGLE_HOLD: register_code(KC_V);   break; // 音声入力
        case TD_STATE_DOUBLE_TAP:  register_code(KC_SPC); break; // 現在地へ
        case TD_STATE_TRIPLE_TAP:  register_code(KC_P);   break; // 駐車場表示
        default: break;
    }
}

static void td_push_reset(tap_dance_state_t *state, void *user_data) {
    switch (td_push_state) {
        case TD_STATE_SINGLE_TAP:  unregister_code(KC_ENT); break;
        case TD_STATE_SINGLE_HOLD: unregister_code(KC_V);   break;
        case TD_STATE_DOUBLE_TAP:  unregister_code(KC_SPC); break;
        case TD_STATE_TRIPLE_TAP:  unregister_code(KC_P);   break;
        default: break;
    }
    td_push_state = TD_STATE_NONE;
}

tap_dance_action_t tap_dance_actions[] = {
    [TD_PUSH] = ACTION_TAP_DANCE_FN_ADVANCED(NULL, td_push_finished, td_push_reset),
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [0] = LAYOUT(
                 KC_UP,
        KC_LEFT, TD(TD_PUSH), KC_RGHT,
                 KC_DOWN
    ),
};

#if defined(ENCODER_MAP_ENABLE)
// 時計回りでズームイン(PgUp)、反時計回りでズームアウト(PgDn)
const uint16_t PROGMEM encoder_map[][NUM_ENCODERS][NUM_DIRECTIONS] = {
    [0] = { ENCODER_CCW_CW(KC_PGDN, KC_PGUP) },
};
#endif
