#pragma once
#include <stdio.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct MemoryEditor MemoryEditor;

MemoryEditor* MemoryEditor_MemoryEditor(void);
void MemoryEditor_destroy(MemoryEditor* self);

void MemoryEditor_DrawWindow(MemoryEditor* self, const char* title, void* mem_data, size_t mem_size, size_t base_display_addr /* = 0x0000 */);

void MemoryEditor_DrawContents(MemoryEditor* self, void* mem_data_void, size_t mem_size, size_t base_display_addr /* = 0x0000 */);

#ifdef __cplusplus
}
#endif
