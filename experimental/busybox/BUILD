package(default_visibility = ["//base:__subpackages__"])

load("//:checksums.bzl", "ARCHITECTURES")
load(":commands.bzl", "BUSYBOX_COMMANDS")

# This works for all architectures because it is just files.
[genrule(
    name = "busybox_" + arch + "_tar",
    srcs = ["@busybox_" + arch + "//file"],
    outs = ["busybox_" + arch + ".tar"],
    cmd = "mkdir busybox; cp $(<) busybox/busybox; cd busybox; \
           if [[ $(<) == *ppc64le* ]]; then \
	     tar -xf busybox ./bin && mv -f ./bin/busybox . && rm -rf ./bin; \
	   fi; \
           for cmd in %s; do \
             ln -s busybox $$cmd; \
           done; \
           cd ..; \
           tar -cf $@ busybox" % " ".join(BUSYBOX_COMMANDS),
) for arch in ARCHITECTURES]
