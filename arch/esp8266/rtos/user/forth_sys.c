#include "FreeRTOS.h"
#include "espressif/esp_common.h"
#include "task.h"

void forth_abort() { 
    printf("Restarting ESP ..\n");
    sdk_system_restart();
}

void forth_yield() { 
    taskYIELD();
}

int forth_free_heap() {
    return (int)xPortGetFreeHeapSize();
}
