#include "shim.h"

#include <functional>

#include "Rts.h"

// Calls to the RTS and to the C code of another package (bytestring), which
// have to be linked in - with the profiled libraries in a profiling build.
extern "C" unsigned char fps_maximum(unsigned char *p, size_t len);

namespace {
// A trivial bit of real C++ (not just C wrapped in extern "C"), so this
// genuinely exercises the C++ toolchain rather than compiling as C in
// disguise.
int add(int a, int b) {
    std::function<int(int, int)> f = [](int a, int b) { return a + b; };
    return f(a, b);
}
}  // namespace

extern "C" int shim_add_point(const ShimPoint *p) {
    unsigned char bytes[2] = {(unsigned char) p->x, (unsigned char) p->y};
    (void) fps_maximum(bytes, 2);
    (void) getNumberOfProcessors();
    return add(p->x, p->y);
}
