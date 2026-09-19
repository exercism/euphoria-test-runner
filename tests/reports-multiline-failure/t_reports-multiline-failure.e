include std/unittest.e

include reports-multiline-failure.ex

set_test_verbosity(TEST_SHOW_ALL)

test_equal("reports entire multiline failure", {{"answer", 42}}, answer())

test_report()
