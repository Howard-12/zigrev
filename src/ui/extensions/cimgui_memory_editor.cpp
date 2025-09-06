#include "imgui.h"
#include "imgui_memory_editor.h"
#include "cimgui_memory_editor.h"

#ifdef __cplusplus
extern "C" {
#endif

MemoryEditor* MemoryEditor_MemoryEditor() {
  return IM_NEW(MemoryEditor)();
}

void MemoryEditor_destroy(MemoryEditor* self) { 
  IM_DELETE(self); 
}

void MemoryEditor_DrawWindow(MemoryEditor* self, const char* title, void* mem_data, size_t mem_size, size_t base_display_addr) {
  self->DrawWindow(title, mem_data, mem_size, base_display_addr);
}

void MemoryEditor_DrawContents(MemoryEditor* self, void* mem_data_void, size_t mem_size, size_t base_display_addr) {
  self->DrawContents(mem_data_void, mem_size, base_display_addr);

}

#ifdef __cplusplus
}
#endif
