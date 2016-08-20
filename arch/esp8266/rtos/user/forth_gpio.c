#include "esp/gpio.h"
#include "pwm.h"
#include "espressif/esp_common.h"
#include "forth_evt.h"

void forth_gpio_mode(int num, int dir) { 
    gpio_direction_t d;
    switch (dir) {
        case 1: d = GPIO_INPUT; break;
        case 2: d = GPIO_OUTPUT; break;
        case 3: d = GPIO_OUT_OPEN_DRAIN; break;
        default: return;
    }
    gpio_enable(num, d); 
}

void forth_gpio_write(int num, int bool_set) { 
    gpio_write(num, bool_set); 
}

int forth_gpio_read(int num) {
    return gpio_read(num);
}

void forth_gpio_set_interrupt(int num, int int_type) {
    gpio_set_interrupt(num, int_type);
}

void forth_pwm_freq(int freq) {
    pwm_set_freq((uint16_t) (freq & 0xFFFF));
}

void forth_pwm_duty(int duty) {
    pwm_set_duty((uint16_t) (duty & 0xFFFF));
}

void __attribute__((weak)) IRAM gpio_interrupt_handler(void) {
    uint32_t status_reg = GPIO.STATUS;
    GPIO.STATUS_CLEAR = status_reg;   
    uint8_t gpio_idx;
    while ((gpio_idx = __builtin_ffs(status_reg))) {
        gpio_idx--;
        status_reg &= ~BIT(gpio_idx);
        if (FIELD2VAL(GPIO_CONF_INTTYPE, GPIO.CONF[gpio_idx])) {
            struct forth_event event = {
                .event_type = EVT_GPIO,
                .event_time = xTaskGetTickCountFromISR() * portTICK_RATE_MS,
                .event_payload = gpio_idx,
                .event_time_us = sdk_system_get_time()
            };
            forth_add_event_isr(&event);
        }
    }
}
