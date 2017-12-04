

cdef extern from "delta.c":
    # copied from delta.h generated by fossil config+make
    int delta_analyze(const char *zDelta,int lenDelta,int *pnCopy,int *pnInsert)
    int delta_apply(const char *zSrc,int lenSrc,const char *zDelta,
                    int lenDelta,char *zOut)
    int delta_output_size(const char *zDelta,int lenDelta)
    void fossil_free(void *p)
    void *fossil_malloc(size_t n)
    int delta_create(const char *zSrc,unsigned int lenSrc,
                     const char *zOut,unsigned int lenOut,char *zDelta)


def test():
    return 1