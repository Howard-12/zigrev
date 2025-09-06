const std = @import("std");
const gl = @import("gl");
const ui = @import("ui/ui.zig");

var procs: gl.ProcTable = undefined;

pub const c = @cImport({
    @cDefine("GLFW_INCLUDE_NONE", "1");
    @cInclude("GLFW/glfw3.h");
    @cInclude("dcimgui.h");
    @cInclude("backends/dcimgui_impl_glfw.h");
    @cInclude("backends/dcimgui_impl_opengl3.h");
    @cInclude("cimgui_memory_editor.h");
});

pub const Config = struct {
    vsync: bool = false,
};

const Self = @This();

window: ?*c.GLFWwindow,
config: Config,
// window_widges: , //#TODO window widget management 
mainport: ui.main_viewport,
md: ?*c.MemoryEditor,

pub fn setup(config: Config) !Self {
    var self = Self{
        .window = null,
        .config = config,
        .mainport = undefined,
        .md = undefined,
    };
    
    // glfw setup
    if (c.glfwInit() != c.GLFW_TRUE)
        return error.GlfwInitFailed;

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 0);
    c.glfwWindowHint(c.GLFW_FLOATING, c.GLFW_TRUE);

    self.window = c.glfwCreateWindow(700, 700, "zigrev", null, null);

    if (self.window == null)
        return error.GlfwWindowsInitFailed;

    c.glfwMakeContextCurrent(self.window);

    if (!procs.init(c.glfwGetProcAddress)) return error.InitFailed;

    gl.makeProcTableCurrent(&procs);

    // imgui
    _ = c.CIMGUI_CHECKVERSION();
    _ = c.ImGui_CreateContext(null);

    const io = c.ImGui_GetIO();
    io.*.ConfigFlags |= c.ImGuiConfigFlags_NavEnableKeyboard;
    io.*.ConfigFlags |= c.ImGuiConfigFlags_DockingEnable;
    io.*.ConfigFlags |= c.ImGuiConfigFlags_ViewportsEnable;

    _ = c.cImGui_ImplGlfw_InitForOpenGL(self.window, true);
    _ = c.cImGui_ImplOpenGL3_InitEx("#version 130");
    

    self.mainport = ui.main_viewport.init();
    self.md = c.MemoryEditor_MemoryEditor();
    
    return self;
}

pub fn run(self: *Self) void {
    var buf: [256]u8 = undefined;
    while (c.glfwWindowShouldClose(self.window) != c.GLFW_TRUE) {
        c.glfwPollEvents();


        c.cImGui_ImplOpenGL3_NewFrame();
        c.cImGui_ImplGlfw_NewFrame();
        c.ImGui_NewFrame();

        _= c.ImGui_DockSpaceOverViewport();
        // c.ImGui_ShowDemoWindow(null);

        // ui 
        self.mainport.draw();

        c.MemoryEditor_DrawWindow(self.md, "mem edit", &buf, buf.len, 0);

        c.ImGui_Render();

        var width: c_int = 0; 
        var height: c_int = 0;
        c.glfwGetFramebufferSize(self.window, &width, &height);
        gl.Viewport(0, 0, width, height);
        gl.ClearColor(0.5, 0.5, 0.5, 1.0);
        gl.Clear(gl.COLOR_BUFFER_BIT);

        c.cImGui_ImplOpenGL3_RenderDrawData(c.ImGui_GetDrawData());

        c.ImGui_UpdatePlatformWindows();
        c.ImGui_RenderPlatformWindowsDefault();

        c.glfwSwapBuffers(self.window);
    }
}

pub fn clean(self: *Self) void {
    // glfw
    c.glfwTerminate();
    if (self.window != null) 
        c.glfwDestroyWindow(self.window);
    gl.makeProcTableCurrent(null);

    // imgui
    c.MemoryEditor_destroy(self.md);
    c.cImGui_ImplGlfw_Shutdown();
    c.cImGui_ImplOpenGL3_Shutdown();
    c.ImGui_DestroyContext(null);
}

