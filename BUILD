load(":dummy.bzl", "dummy_dir", "dummy_user", "sleeper")

sleeper(
    name = "i_sleep",
)

dummy_dir(
    name = "mydummy",
    sleep_on = ":i_sleep",
)

dummy_user(
    name = "user",
    use = [":mydummy"],
)