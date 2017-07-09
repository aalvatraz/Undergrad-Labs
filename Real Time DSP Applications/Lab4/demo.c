#include<DSP28x_Project.h>
#include"adrian.h"

int main()
{
	EALLOW;


	Init_LCD();

	char* diego_name = "Diego";

	LCD_string(diego_name);

	while(1);
}
