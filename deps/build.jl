using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libxsum"], :libxsum),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/stevengj/xsumBuilder/releases/download/v1.0.0+1"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/xsum.v1.0.0.aarch64-linux-gnu.tar.gz", "473983348b56294de7ef0efb1c2807c743c05945519c49c4eb8571fd773b7f58"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/xsum.v1.0.0.aarch64-linux-musl.tar.gz", "6fd30b10ecb5c00cf5b6436662a1cf1fb1d45471296b262e91d1ab449a208a9a"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/xsum.v1.0.0.arm-linux-gnueabihf.tar.gz", "06a472fafa5052b7ec25a9d41e55fa2f2e4dc36afdac4c944ae972e94d8f22a3"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/xsum.v1.0.0.arm-linux-musleabihf.tar.gz", "f27d6d7617b6a35d6f3f2b2e0be076648a4d7fc2092f06c7a0d77963b0a96adc"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/xsum.v1.0.0.i686-linux-gnu.tar.gz", "8fe754962757ca1c2bfdc0d019568db0af61269383f9b4d95dbfea0cffda2895"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/xsum.v1.0.0.i686-linux-musl.tar.gz", "3aa8d3c9d24c5eaf3c8328294b471496ac86643eb683e0c8b16f2ec2d76f1951"),
    Windows(:i686) => ("$bin_prefix/xsum.v1.0.0.i686-w64-mingw32.tar.gz", "dea1ddfedb4585424428cc8bc137d5c026a4be888887d3b7fc38709ba62e5fb9"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/xsum.v1.0.0.powerpc64le-linux-gnu.tar.gz", "e7210565ebfc4668ed36c3488a2fc9ac0c80ac19c6d346a94d3e5259066f67ef"),
    MacOS(:x86_64) => ("$bin_prefix/xsum.v1.0.0.x86_64-apple-darwin14.tar.gz", "ef445ad5ad44554c15395e0110ed8a1b0b1f5575db0bad8ea26b2fa4a4bf12c0"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/xsum.v1.0.0.x86_64-linux-gnu.tar.gz", "c9139563bb270dd3e48432bada79932a50eb0b521ec1268a2f029c0c4a2c152d"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/xsum.v1.0.0.x86_64-linux-musl.tar.gz", "8a93c0037a9cc5ae40dd7b2e47796bbde9143c57f17f34869466f5a777df2f6a"),
    FreeBSD(:x86_64) => ("$bin_prefix/xsum.v1.0.0.x86_64-unknown-freebsd11.1.tar.gz", "011df9bf85608cc95b640015d3772a36efe8308d7c490d1707ae94566b8600b4"),
    Windows(:x86_64) => ("$bin_prefix/xsum.v1.0.0.x86_64-w64-mingw32.tar.gz", "d3ea0fa675e2cda6305067ffd64e189c37d81fb0108c9c719b9c5012eaaa9d82"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
