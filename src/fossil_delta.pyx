cdef extern from "alloc_map.h":
    pass


cdef extern from "delta.c":
    # copied from delta.h generated by fossil config+make
    int delta_analyze(const char *zDelta,int lenDelta,int *pnCopy,int *pnInsert)
    int delta_apply(const char *zSrc,int lenSrc,const char *zDelta,
                    int lenDelta,char *zOut)
    int delta_output_size(const char *zDelta,int lenDelta)
    int delta_create(const char *zSrc,unsigned int lenSrc,
                     const char *zOut,unsigned int lenOut,char *zDelta)


def create(bytes src not None, bytes dst not None):
    cdef bytearray deltabuf
    cdef int deltalen
    deltabuf = bytearray(len(dst) + 60)
    deltalen = delta_create(src, len(src), dst, len(dst), deltabuf)
    return bytes(deltabuf[:deltalen])


def create_into(bytes src not None, bytes dst not None, bytearray deltabuf not None):
    if len(deltabuf) < len(dst) + 60:
        raise ValueError('deltabuf must be len(dst) + 60 or greater')
    return delta_create(src, len(src), dst, len(dst), deltabuf)


def apply(bytes src not None, bytes delta not None):
    cdef bytearray dstbuf
    cdef int outlen
    dstbuf = bytearray(delta_output_size(delta, len(delta)))
    outlen = delta_apply(src, len(src), delta, len(delta), dstbuf)
    if outlen == -1:
        raise ValueError('malformed delta, or wrong base')
    return bytes(dstbuf[:outlen])


def apply_into(bytes src not None, bytes delta not None, bytearray dstbuf not None):
    cdef int outlen
    cdef int minbufsize = 0
    minbufsize = delta_output_size(delta, len(delta))
    if len(dstbuf) < minbufsize:
        raise ValueError(
            'dstbuf too small, must be at least ' + repr(minbufsize))
    outlen = delta_apply(src, len(src), delta, len(delta), dstbuf)
    if outlen == -1:
        raise ValueError('malformed delta, or wrong base')
    return outlen


def test():
    assert apply('a', create('a', 'b')) == 'b'
    buf = bytearray(61)
    delta = str(buf[:create_into('a', 'b', buf)])
    assert buf[:apply_into('a', delta, buf)] == 'b'
