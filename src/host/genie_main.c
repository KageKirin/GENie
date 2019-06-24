/**
 * \file   genie_main.c
 * \brief  Program entry point.
 * \author Copyright (c) 2002-2012 Jason Perkins and the Premake project
 */

#include "genie.h"

int main(int argc, const char** argv)
{
	lua_State* L;
	int z = OKAY;

	L = luaL_newstate();
	luaL_openlibs(L);
	z = genie_init(L);

	/* push the location of the GENie executable */
	genie_locate(L, argv[0]);
	lua_setglobal(L, "_GENIE_COMMAND");

	if (z == OKAY)
	{
		z = genie_execute(L, argc, argv);
	}
	
	lua_close(L);
	return z;
}
