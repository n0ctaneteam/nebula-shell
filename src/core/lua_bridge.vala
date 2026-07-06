namespace NebulaShell {
    public class LuaBridge : Object {
        private Lua.State L;

        public LuaBridge() {
            L = Lua.luaL_newstate();
            Lua.luaL_openlibs(L);
            setup_package_path();
            Logger.debug("LuaBridge initialized");
        }


        private void setup_package_path() {
            string user_widgets = Path.build_filename(
                Environment.get_user_config_dir(),
                "nebula-shell",
                "widgets",
                "?.lua");
            string user_widgets_init = Path.build_filename(
                Environment.get_user_config_dir(),
                "nebula-shell",
                "widgets",
                "?",
                "init.lua");
            string system_widgets = "/etc/nebula-shell/widgets/?.lua";
            string system_widgets_init = "/etc/nebula-shell/widgets/?/init.lua";
            string user_dir = Path.build_filename(
                Environment.get_user_config_dir(),
                "nebula-shell",
                "?.lua");
            string system_dir = "/etc/nebula-shell/?.lua";

            string lua_path = "%s;%s;%s;%s;%s;%s".printf(
                user_widgets, user_widgets_init,
                system_widgets, system_widgets_init,
                user_dir, system_dir);

            Lua.lua_getglobal(L, "package");
            Lua.lua_getfield(L, -1, "path");
            string current_path = Lua.lua_tostring(L, -1);
            Lua.lua_pop(L, 1);

            string new_path = "%s;%s".printf(lua_path, current_path);
            Lua.lua_pushstring(L, new_path);
            Lua.lua_setfield(L, -2, "path");
            Lua.lua_pop(L, 1);
        }

        public bool do_file(string path) {
            int result = Lua.luaL_dofile(L, path);
            if (result != 0) {
                string err = Lua.lua_tostring(L, -1);
                Logger.error(@"Lua error in $(path): $(err)");
                Lua.lua_pop(L, 1);
                return false;
            }
            return true;
        }

        public bool do_string(string code) {
            int result = Lua.luaL_dostring(L, code);
            if (result != 0) {
                string err = Lua.lua_tostring(L, -1);
                Logger.error(@"Lua error: $(err)");
                Lua.lua_pop(L, 1);
                return false;
            }
            return true;
        }

        public bool load_file(string path) {
            return do_file(path);
        }

        public void push_string(string s) {
            Lua.lua_pushstring(L, s);
        }

        public void push_number(double n) {
            Lua.lua_pushnumber(L, n);
        }

        public void push_boolean(bool b) {
            Lua.lua_pushboolean(L, b ? 1 : 0);
        }

        public void push_pointer(void* p) {
            Lua.lua_pushlightuserdata(L, p);
        }

        public void push_nil() {
            Lua.lua_pushnil(L);
        }

        public string? get_string(int index) {
            if (Lua.lua_type(L, index) != Lua.TSTRING) return null;
            return Lua.lua_tostring(L, index);
        }

        public double? get_number(int index) {
            if (Lua.lua_type(L, index) != Lua.TNUMBER) return null;
            return Lua.lua_tonumber(L, index);
        }

        public bool? get_boolean(int index) {
            if (Lua.lua_type(L, index) != Lua.TBOOLEAN) return null;
            return Lua.lua_toboolean(L, index) != 0;
        }

        public void* get_pointer(int index) {
            if (Lua.lua_type(L, index) != Lua.TLIGHTUSERDATA) return null;
            return Lua.lua_touserdata(L, index);
        }

        public bool is_table(int index) {
            return Lua.lua_type(L, index) == Lua.TTABLE;
        }

        public bool is_function(int index) {
            return Lua.lua_type(L, index) == Lua.TFUNCTION;
        }

        public void new_table() {
            Lua.lua_newtable(L);
        }

        public void set_field(string key) {
            Lua.lua_setfield(L, -3, key);
        }

        public bool get_field(int index, string key) {
            Lua.lua_getfield(L, index, key);
            return Lua.lua_type(L, -1) != Lua.TNIL;
        }

        public void set_global(string name) {
            Lua.lua_setglobal(L, name);
        }

        public bool get_global(string name) {
            Lua.lua_getglobal(L, name);
            return Lua.lua_type(L, -1) != Lua.TNIL;
        }

        public void pop(int n = 1) {
            Lua.lua_pop(L, n);
        }

        public int get_top() {
            return Lua.lua_gettop(L);
        }

        public bool call(int nargs, int nresults) {
            int result = Lua.lua_pcall(L, nargs, nresults, 0);
            if (result != 0) {
                string err = Lua.lua_tostring(L, -1);
                Logger.error(@"Lua call error: $(err)");
                Lua.lua_pop(L, 1);
                return false;
            }
            return true;
        }

        public bool call_function(string name, int nargs = 0, int nresults = 0) {
            Lua.lua_getglobal(L, name);
            if (!is_function(-1)) {
                Logger.error(@"Function not found: $(name)");
                Lua.lua_pop(L, 1);
                return false;
            }
            int result = Lua.lua_pcall(L, nargs, nresults, 0);
            if (result != 0) {
                string err = Lua.lua_tostring(L, -1);
                Logger.error(@"Lua call error in '$(name)': $(err)");
                Lua.lua_pop(L, 1);
                return false;
            }
            return true;
        }

        public void register_function(string name, owned Lua.LuaCFunction func) {
            Lua.lua_pushcclosure(L, func, 0);
            Lua.lua_setglobal(L, name);
        }

        public void* get_pointer_global(string name) {
            if (!get_global(name)) return null;
            void* p = get_pointer(-1);
            pop();
            return p;
        }

        public string? get_string_global(string name) {
            if (!get_global(name)) return null;
            string? s = get_string(-1);
            pop();
            return s;
        }

        public double? get_number_global(string name) {
            if (!get_global(name)) return null;
            double? n = get_number(-1);
            pop();
            return n;
        }

        public void push_value(int index) {
            Lua.lua_pushvalue(L, index);
        }

        public string[] get_table_keys() {
            string[] keys = {};
            Lua.lua_pushnil(L);
            while (Lua.lua_next(L, -2) != 0) {
                if (Lua.lua_type(L, -2) == Lua.TSTRING) {
                    keys += Lua.lua_tostring(L, -2);
                }
                Lua.lua_pop(L, 1);
            }
            return keys;
        }

        public int get_table_length() {
            int len = 0;
            Lua.lua_pushnil(L);
            while (Lua.lua_next(L, -2) != 0) {
                len++;
                Lua.lua_pop(L, 1);
            }
            return len;
        }

        public bool is_pointer(int index) {
            return Lua.lua_type(L, index) == Lua.TLIGHTUSERDATA;
        }

        public void* get_global_widget(string id) {
            string global_name = "_widget_%s".printf(id);
            return get_pointer_global(global_name);
        }

        public void set_global_widget(string id, void* widget) {
            string global_name = "_widget_%s".printf(id);
            push_pointer(widget);
            Lua.lua_setglobal(L, global_name);
        }

        public void remove_global_widget(string id) {
            string global_name = "_widget_%s".printf(id);
            Lua.lua_pushnil(L);
            Lua.lua_setglobal(L, global_name);
        }
    }
}
