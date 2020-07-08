//Modify this file to change what commands output to your statusbar, and recompile using the make command.
static const Block blocks[] = {
	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/
	{"", " cat ~/.pacupdate | sed /📦0/d",					3600,		0},
    
	{"",	" bandwidth ",	1,	0},

	 {"  ",	" spotify-status ",	1,	0},
	
	{"   ",	" free -h | awk '/Mem:/ NR>1 {printf $3} NR>1 {print $7}' | sed 's/i/ ~ /1' | sed 's/i//1' ",	5,	0},
	
	{"   ",	" sensors | awk '/Tctl:/ {print $2}' | sed 's/+//g' ",		1,	0},

	{"  ",	" volume ",	0,	10},

	{"   ",	" clock",	60,	0},
};

//sets delimeter between status commands. NULL character ('\0') means no delimeter.
static char delim = ' ';
