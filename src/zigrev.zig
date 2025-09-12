const std = @import("std");
const gl = @import("gl");
const ui_dep = @import("ui/ui.zig");
const Process = @import("debugger/process.zig");
pub const SharedState = @import("shared_state.zig");
const builtin = @import("builtin");

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


// gpa: std.heap.GeneralPurposeAllocator(.{}),
allocator: std.mem.Allocator,
window: ?*c.GLFWwindow,
config: Config,
ui: ui_dep,
state: SharedState,

pub fn setup(config: Config) !Self {
    var self = Self{
        // .gpa = undefined,
        .allocator = undefined,
        .window = null,
        .config = config,
        .ui = undefined,
        .state = undefined,
    };

    // TODO: General prupose allocator does not work. The reason could be 
    // that the backend library links against libc.
    self.allocator = std.heap.c_allocator;

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

    imgui_style();

    const io = c.ImGui_GetIO();
    io.*.ConfigFlags |= c.ImGuiConfigFlags_NavEnableKeyboard;
    io.*.ConfigFlags |= c.ImGuiConfigFlags_DockingEnable;
    io.*.ConfigFlags |= c.ImGuiConfigFlags_ViewportsEnable;

    _ = c.cImGui_ImplGlfw_InitForOpenGL(self.window, true);
    _ = c.cImGui_ImplOpenGL3_InitEx("#version 130");

    self.state = try SharedState.init(self.allocator);

    self.ui = ui_dep.init();

    return self;
}

pub fn run(self: *Self) !void {
    while (c.glfwWindowShouldClose(self.window) != c.GLFW_TRUE) {
        c.glfwPollEvents();

        c.cImGui_ImplOpenGL3_NewFrame();
        c.cImGui_ImplGlfw_NewFrame();
        c.ImGui_NewFrame();

        _ = c.ImGui_DockSpaceOverViewport();
        // c.ImGui_ShowDemoWindow(null);

        // ui
        try self.ui.update(&self.state);
        self.ui.draw(&self.state);

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
    // imgui
    self.ui.deinit();
    c.cImGui_ImplOpenGL3_Shutdown();
    c.cImGui_ImplGlfw_Shutdown();
    c.ImGui_DestroyContext(null);

    // glfw
    if (self.window != null)
        c.glfwDestroyWindow(self.window);
    gl.makeProcTableCurrent(null);
    c.glfwTerminate();

    self.state.clean();
}

fn imgui_style() void {
    var style: *c.ImGuiStyle = c.ImGui_GetStyle();
    var colours: *[60]c.ImVec4_t = &style.*.Colors;

    colours[c.ImGuiCol_Text] = c.ImVec4{ .x = 1.000, .y = 1.000, .z = 1.000, .w = 1.000 };
    colours[c.ImGuiCol_TextDisabled] = c.ImVec4{ .x = 0.500, .y = 0.500, .z = 0.500, .w = 1.000 };
    colours[c.ImGuiCol_WindowBg] = c.ImVec4{ .x = 0.180, .y = 0.180, .z = 0.180, .w = 1.000 };
    colours[c.ImGuiCol_ChildBg] = c.ImVec4{ .x = 0.280, .y = 0.280, .z = 0.280, .w = 0.000 };
    colours[c.ImGuiCol_PopupBg] = c.ImVec4{ .x = 0.313, .y = 0.313, .z = 0.313, .w = 1.000 };
    colours[c.ImGuiCol_Border] = c.ImVec4{ .x = 0.266, .y = 0.266, .z = 0.266, .w = 1.000 };
    colours[c.ImGuiCol_BorderShadow] = c.ImVec4{ .x = 0.000, .y = 0.000, .z = 0.000, .w = 0.000 };
    colours[c.ImGuiCol_FrameBg] = c.ImVec4{ .x = 0.160, .y = 0.160, .z = 0.160, .w = 1.000 };
    colours[c.ImGuiCol_FrameBgHovered] = c.ImVec4{ .x = 0.200, .y = 0.200, .z = 0.200, .w = 1.000 };
    colours[c.ImGuiCol_FrameBgActive] = c.ImVec4{ .x = 0.280, .y = 0.280, .z = 0.280, .w = 1.000 };
    colours[c.ImGuiCol_TitleBg] = c.ImVec4{ .x = 0.148, .y = 0.148, .z = 0.148, .w = 1.000 };
    colours[c.ImGuiCol_TitleBgActive] = c.ImVec4{ .x = 0.148, .y = 0.148, .z = 0.148, .w = 1.000 };
    colours[c.ImGuiCol_TitleBgCollapsed] = c.ImVec4{ .x = 0.148, .y = 0.148, .z = 0.148, .w = 1.000 };
    colours[c.ImGuiCol_MenuBarBg] = c.ImVec4{ .x = 0.195, .y = 0.195, .z = 0.195, .w = 1.000 };
    colours[c.ImGuiCol_ScrollbarBg] = c.ImVec4{ .x = 0.160, .y = 0.160, .z = 0.160, .w = 1.000 };
    colours[c.ImGuiCol_ScrollbarGrab] = c.ImVec4{ .x = 0.277, .y = 0.277, .z = 0.277, .w = 1.000 };
    colours[c.ImGuiCol_ScrollbarGrabHovered] = c.ImVec4{ .x = 0.300, .y = 0.300, .z = 0.300, .w = 1.000 };
    colours[c.ImGuiCol_ScrollbarGrabActive] = c.ImVec4{ .x = 1.000, .y = 0.391, .z = 0.000, .w = 1.000 };
    colours[c.ImGuiCol_CheckMark] = c.ImVec4{ .x = 1.000, .y = 1.000, .z = 1.000, .w = 1.000 };
    colours[c.ImGuiCol_SliderGrab] = c.ImVec4{ .x = 0.391, .y = 0.391, .z = 0.391, .w = 1.000 };
    colours[c.ImGuiCol_SliderGrabActive] = c.ImVec4{ .x = 1.000, .y = 0.391, .z = 0.000, .w = 1.000 };
    colours[c.ImGuiCol_Button] = c.ImVec4{ .x = 1.000, .y = 1.000, .z = 1.000, .w = 0.000 };
    colours[c.ImGuiCol_ButtonHovered] = c.ImVec4{ .x = 1.000, .y = 1.000, .z = 1.000, .w = 0.156 };
    colours[c.ImGuiCol_ButtonActive] = c.ImVec4{ .x = 1.000, .y = 1.000, .z = 1.000, .w = 0.391 };
    colours[c.ImGuiCol_Header] = c.ImVec4{ .x = 0.313, .y = 0.313, .z = 0.313, .w = 1.000 };
    colours[c.ImGuiCol_HeaderHovered] = c.ImVec4{ .x = 0.469, .y = 0.469, .z = 0.469, .w = 1.000 };
    colours[c.ImGuiCol_HeaderActive] = c.ImVec4{ .x = 0.469, .y = 0.469, .z = 0.469, .w = 1.000 };
    colours[c.ImGuiCol_SeparatorHovered] = c.ImVec4{ .x = 0.391, .y = 0.391, .z = 0.391, .w = 1.000 };
    colours[c.ImGuiCol_SeparatorActive] = c.ImVec4{ .x = 1.000, .y = 0.391, .z = 0.000, .w = 1.000 };
    colours[c.ImGuiCol_ResizeGrip] = c.ImVec4{ .x = 1.000, .y = 1.000, .z = 1.000, .w = 0.250 };
    colours[c.ImGuiCol_ResizeGripHovered] = c.ImVec4{ .x = 1.000, .y = 1.000, .z = 1.000, .w = 0.670 };
    colours[c.ImGuiCol_ResizeGripActive] = c.ImVec4{ .x = 1.000, .y = 0.391, .z = 0.000, .w = 1.000 };
    colours[c.ImGuiCol_Tab] = c.ImVec4{ .x = 0.098, .y = 0.098, .z = 0.098, .w = 1.000 };
    colours[c.ImGuiCol_TabHovered] = c.ImVec4{ .x = 0.352, .y = 0.352, .z = 0.352, .w = 1.000 };
    colours[c.ImGuiCol_TabActive] = c.ImVec4{ .x = 0.195, .y = 0.195, .z = 0.195, .w = 1.000 };
    colours[c.ImGuiCol_TabUnfocused] = c.ImVec4{ .x = 0.098, .y = 0.098, .z = 0.098, .w = 1.000 };
    colours[c.ImGuiCol_TabUnfocusedActive] = c.ImVec4{ .x = 0.195, .y = 0.195, .z = 0.195, .w = 1.000 };
    colours[c.ImGuiCol_DockingPreview] = c.ImVec4{ .x = 1.000, .y = 0.391, .z = 0.000, .w = 0.781 };
    colours[c.ImGuiCol_DockingEmptyBg] = c.ImVec4{ .x = 0.180, .y = 0.180, .z = 0.180, .w = 1.000 };
    colours[c.ImGuiCol_PlotLines] = c.ImVec4{ .x = 0.469, .y = 0.469, .z = 0.469, .w = 1.000 };
    colours[c.ImGuiCol_PlotLinesHovered] = c.ImVec4{ .x = 1.000, .y = 0.391, .z = 0.000, .w = 1.000 };
    colours[c.ImGuiCol_PlotHistogram] = c.ImVec4{ .x = 0.586, .y = 0.586, .z = 0.586, .w = 1.000 };
    colours[c.ImGuiCol_PlotHistogramHovered] = c.ImVec4{ .x = 1.000, .y = 0.391, .z = 0.000, .w = 1.000 };
    colours[c.ImGuiCol_TextSelectedBg] = c.ImVec4{ .x = 1.000, .y = 1.000, .z = 1.000, .w = 0.156 };
    colours[c.ImGuiCol_DragDropTarget] = c.ImVec4{ .x = 1.000, .y = 0.391, .z = 0.000, .w = 1.000 };
    colours[c.ImGuiCol_NavHighlight] = c.ImVec4{ .x = 1.000, .y = 0.391, .z = 0.000, .w = 1.000 };
    colours[c.ImGuiCol_NavWindowingHighlight] = c.ImVec4{ .x = 1.000, .y = 0.391, .z = 0.000, .w = 1.000 };
    colours[c.ImGuiCol_NavWindowingDimBg] = c.ImVec4{ .x = 0.000, .y = 0.000, .z = 0.000, .w = 0.586 };
    colours[c.ImGuiCol_ModalWindowDimBg] = c.ImVec4{ .x = 0.000, .y = 0.000, .z = 0.000, .w = 0.586 };
    colours[c.ImGuiCol_Separator] = colours[c.ImGuiCol_Border];

    style.ChildRounding = 4.0;
    style.FrameBorderSize = 1.0;
    style.FrameRounding = 2.0;
    style.GrabMinSize = 7.0;
    style.PopupRounding = 2.0;
    style.ScrollbarRounding = 12.0;
    style.ScrollbarSize = 13.0;
    style.TabBorderSize = 1.0;
    style.TabRounding = 0.0;
    style.WindowRounding = 4.0;
}
