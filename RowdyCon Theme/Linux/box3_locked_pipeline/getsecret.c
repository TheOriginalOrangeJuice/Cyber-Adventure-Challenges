#include <fcntl.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

static const char *PAYLOAD_PATH = "/usr/local/.hidden_secret/.encoded_payload";
static const char *EXPECTED_OWNER = "joshua_silva";
static const char *PIPE_REQUIRED_B64 = "VGhlIG91dHB1dCBpc27igJl0IG1lYW50IHRvIGJlIHJlYWQgZGlyZWN0bHkuCgpObyBwb2ludCBpbiBzYXZpbmcgdGhpbmdzIGluIHBsYWludGV4dCB3aGVuIHRoZSBzeXN0ZW0gaGFzIHRoZSB0b29scyB0byB0cmFuc2xhdGUgdGhlIG1vc3QgYmFzaWMgY2lwaGVycy4gRmVlZCB0aGUgb3V0cHV0IGJhY2sgaW50byB0aGUgc3lzdGVtIGFuZCBsZXQgaXQgdHJhbnNsYXRlIGl0cyBvd24gbWVzcy4KCkFueW9uZSBsb29raW5nIGF0IHRoaXMgd2lsbCBuZWVkIHRvIGxldCB0aGUgbWFjaGluZSBkbyB0aGUgZGVjb2RpbmcuCgotIFRoZSBuaWNlc3QgIlJlZCBUZWFtZXIiIFlvdSBrbm93LiA=\n";

static int emit_payload(void) {
    int fd = open(PAYLOAD_PATH, O_RDONLY);
    if (fd < 0) {
        return -1;
    }
    char buf[4096];
    ssize_t n;
    while ((n = read(fd, buf, sizeof buf)) > 0) {
        if (write(STDOUT_FILENO, buf, n) != n) {
            close(fd);
            return -1;
        }
    }
    close(fd);
    return n < 0 ? -1 : 0;
}

static uid_t expected_uid(void) {
    struct passwd *pw = getpwnam(EXPECTED_OWNER);
    return pw ? pw->pw_uid : (uid_t)-1;
}

int main(int argc, char **argv) {
    const char *invoker = (argc > 1) ? argv[1] : "/home/linuxRCC3/decrypt.sh";
    uid_t expect = expected_uid();
    struct stat st;

    /* Validate the wrapper script ownership. */
    if (expect == (uid_t)-1 || stat(invoker, &st) != 0 || st.st_uid != expect) {
        const char *msg = "Access denied: decrypt script must be owned by \"joshua_silva\"\n";
        (void)write(STDERR_FILENO, msg, strlen(msg));
        return 1;
    }

    /* Validate executability. */
    if (!(st.st_mode & S_IXUSR)) {
        const char *msg = "Execution blocked: decrypt script is not executable.\n";
        (void)write(STDERR_FILENO, msg, strlen(msg));
        return 1;
    }

    /* Enforce piping: refuse direct terminal output. */
    if (isatty(STDOUT_FILENO)) {
        (void)write(STDOUT_FILENO, PIPE_REQUIRED_B64, strlen(PIPE_REQUIRED_B64));
        return 1;
    }

    if (emit_payload() != 0) {
        (void)write(STDOUT_FILENO, PIPE_REQUIRED_B64, strlen(PIPE_REQUIRED_B64));
        return 1;
    }

    return 0;
}
