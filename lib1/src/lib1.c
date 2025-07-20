int cong(int x, int y)
{
    return x+y;
}

int nhan(int x, int y)
{
    int result = 0;
    for(int i = 0; i < y; i++)
    {
        result = cong(result, x);
    }
    return result;
}
