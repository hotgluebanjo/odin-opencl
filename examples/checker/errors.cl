void add_one(__global float *x) {
    *x += 1;
}

void square(float x) {
    return x * x;
}

__kernel void square_kernel(__global float *src, __global float *dst, int n_samples) {
    int i = get_global_id(0);
    if (i >= m_samples) {
        return;
    }
    uint32_t x = 200;
    float x = float(i);
    add_one(&x);
    dst[i] = square(src[i]);
}
