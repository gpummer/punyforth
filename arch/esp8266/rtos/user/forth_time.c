#include "FreeRTOS.h"
#include "task.h"
#include "espressif/esp_common.h"

void forth_delay_ms(int millis) {
    vTaskDelay(millis / portTICK_RATE_MS);
}

int forth_time_ms() {
    return xTaskGetTickCount() * portTICK_RATE_MS;
}

/**
 * Delay microseconds
 *
 * sdk os_delay_us has only 16bits, so mask them
 */
void forth_delay_us(unsigned int microseconds) {
    sdk_os_delay_us(microseconds & 0x0ffff);
}
