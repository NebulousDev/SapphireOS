/*
    Sapphire OS
    Ben Ratcliff 2022
*/

/* 
    Entry point to the kernel. 
    This function is called from the bootloader at startup.
*/
__attribute__ ((section (".kernel_start")))
void enter_kernel()
{
    char* pBuff = (char*)0xb8000;
    char* pMsg = "Hello from the kernel!";

    pBuff += 160 * 3;

    while(*pMsg)
    {
        *pBuff++ = *pMsg++;
        *pBuff++ = 0x9f;
    }

    while(1);

    return;
}