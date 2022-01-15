
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