MyProvider = provider(fields=['dir'])

def _sleeper(ctx):
    f = ctx.actions.declare_file(ctx.label.name + ".txt")
    ctx.actions.run_shell(
        inputs = [],
        outputs = [f],
        command = "sleep 5 && echo Hello > {}".format(f.path),
    )
    return DefaultInfo(
        files = depset(direct = [f]),
    )

sleeper = rule(
    implementation = _sleeper,
    attrs = {},
)

def _impl(ctx):
    outdir = ctx.actions.declare_directory(ctx.label.name + "/lib")
    inputs = []
    if ctx.attr.sleep_on:
        inputs = ctx.files.sleep_on
    ctx.actions.run_shell(
        inputs = inputs,
        outputs = [outdir],
        # command = "rm -r {d} && mkdir {d}".format(d=outdir.path),
        command = "",
    )
    return MyProvider(dir=outdir)

dummy_dir = rule(
    implementation = _impl,
    attrs = {
        "sleep_on": attr.label(),
    },
)

def _user(ctx):
    trf = []
    for dep in ctx.attr.use:
        trf.append(dep[MyProvider].dir)
    out = ctx.actions.declare_file("user.bat")
    ctx.actions.do_nothing(
        mnemonic = "JustWaiting",
        inputs = trf,
    )
    ctx.actions.write(
        out,
        """
        @echo off
        echo ------------CURRENT DIR--------------
        dir
        echo ------------mydummy DIR--------------
        dir mydummy
        """,
        is_executable = True,
    )
    return DefaultInfo(
        runfiles = ctx.runfiles(transitive_files= depset(direct = trf)),
        executable = out,
    )

dummy_user = rule(
    implementation = _user,
    attrs = {
        "use": attr.label_list(allow_files=True),
    },
    executable = True,
)