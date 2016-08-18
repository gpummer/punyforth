#include "FreeRTOS.h"
#include "espressif/esp_common.h"

div_t IRAM forth_divmod(int a, int b) { return div(a,b); }
int IRAM forth_random() { return rand(); }
