#ifndef DEBUG_H
#define DEBUG_H

#include <string.h>



#define __FILENAME__ (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : \
                      (strrchr(__FILE__, '\\') ? strrchr(__FILE__, '\\') + 1 : __FILE__))

#ifndef NDEBUG
  #define DBG(fmt, ...) \
  fprintf(stderr, "[%s:%d] " fmt "\n", __FILENAME__, __LINE__, ##__VA_ARGS__)
#else
  #define DBG(...) ((void)0)
#endif

#endif
