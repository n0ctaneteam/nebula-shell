[CCode (cprefix = "lua", cheader_filename = "lua.h,lauxlib.h,lualib.h")]
namespace Lua {
    [CCode (cname = "lua_State", free_function = "lua_close")]
    [Compact]
    public class State {
        public State();
    }

    [CCode (cname = "luaL_newstate")]
    public State luaL_newstate();

    [CCode (cname = "luaL_openlibs")]
    public void luaL_openlibs(State L);

    [CCode (cname = "luaL_dofile")]
    public int luaL_dofile(State L, string filename);

    [CCode (cname = "luaL_dostring")]
    public int luaL_dostring(State L, string str);

    [CCode (cname = "luaL_loadstring")]
    public int luaL_loadstring(State L, string s);

    [CCode (cname = "lua_pcall")]
    public int lua_pcall(State L, int nargs, int nresults, int errfunc);

    [CCode (cname = "lua_getglobal")]
    public void lua_getglobal(State L, string name);

    [CCode (cname = "lua_setglobal")]
    public void lua_setglobal(State L, string name);

    [CCode (cname = "lua_pushnil")]
    public void lua_pushnil(State L);

    [CCode (cname = "lua_pushboolean")]
    public void lua_pushboolean(State L, int b);

    [CCode (cname = "lua_pushnumber")]
    public void lua_pushnumber(State L, double n);

    [CCode (cname = "lua_pushinteger")]
    public void lua_pushinteger(State L, long n);

    [CCode (cname = "lua_pushstring")]
    public void lua_pushstring(State L, string s);

    [CCode (cname = "lua_pushlightuserdata")]
    public void lua_pushlightuserdata(State L, void* p);

    [CCode (cname = "lua_toboolean")]
    public int lua_toboolean(State L, int index);

    [CCode (cname = "lua_tonumber")]
    public double lua_tonumber(State L, int index);

    [CCode (cname = "lua_tointeger")]
    public long lua_tointeger(State L, int index);

    [CCode (cname = "lua_tostring")]
    public unowned string lua_tostring(State L, int index);

    [CCode (cname = "lua_touserdata")]
    public void* lua_touserdata(State L, int index);

    [CCode (cname = "lua_getfield")]
    public int lua_getfield(State L, int index, string k);

    [CCode (cname = "lua_setfield")]
    public void lua_setfield(State L, int index, string k);

    [CCode (cname = "lua_createtable")]
    public void lua_createtable(State L, int narr, int nrec);

    [CCode (cname = "lua_newtable")]
    public void lua_newtable(State L);

    [CCode (cname = "lua_next")]
    public int lua_next(State L, int index);

    [CCode (cname = "lua_pushvalue")]
    public void lua_pushvalue(State L, int index);

    [CCode (cname = "lua_pop")]
    public void lua_pop(State L, int n);

    [CCode (cname = "lua_remove")]
    public void lua_remove(State L, int index);

    [CCode (cname = "lua_rawgeti")]
    public int lua_rawgeti(State L, int index, long n);

    [CCode (cname = "lua_rawseti")]
    public void lua_rawseti(State L, int index, long n);

    [CCode (cname = "lua_type")]
    public int lua_type(State L, int index);

    [CCode (cname = "lua_typename")]
    public unowned string lua_typename(State L, int tp);

    [CCode (cname = "lua_error")]
    public int lua_error(State L);

    [CCode (cname = "lua_settop")]
    public void lua_settop(State L, int index);

    [CCode (cname = "lua_gettop")]
    public int lua_gettop(State L);

    [CCode (cname = "lua_pushcclosure")]
    public void lua_pushcclosure(State L, LuaCFunction fn, int n);

    [CCode (cname = "lua_atpanic")]
    public LuaCFunction lua_atpanic(State L, LuaCFunction panicf);

    [CCode (cname = "lua_close")]
    public void lua_close(State L);

    [CCode (cname = "LUA_GLOBALSINDEX")]
    public const int GLOBALSINDEX;

    [CCode (cname = "LUA_MULTRET")]
    public const int MULTRET;

    [CCode (cname = "LUA_REGISTRYINDEX")]
    public const int REGISTRYINDEX;

    [CCode (cname = "LUA_TNIL")]
    public const int TNIL;
    [CCode (cname = "LUA_TBOOLEAN")]
    public const int TBOOLEAN;
    [CCode (cname = "LUA_TNUMBER")]
    public const int TNUMBER;
    [CCode (cname = "LUA_TSTRING")]
    public const int TSTRING;
    [CCode (cname = "LUA_TTABLE")]
    public const int TTABLE;
    [CCode (cname = "LUA_TFUNCTION")]
    public const int TFUNCTION;
    [CCode (cname = "LUA_TUSERDATA")]
    public const int TUSERDATA;
    [CCode (cname = "LUA_TLIGHTUSERDATA")]
    public const int TLIGHTUSERDATA;

    [CCode (cname = "lua_CFunction", has_target = false)]
    public delegate int LuaCFunction(State L);
}
