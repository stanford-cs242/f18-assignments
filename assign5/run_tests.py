import os
import sys
import unittest
import subprocess
import re

# RUN FROM assign5/program

TESTS = {
    "binop": "Success: 5",
    "block": "Success: 1",
    "func_call": "Success: 8",
    "load_invalid": "Error",
    "load_store": "Success: 8",
    "local": "Success: 24",
    "loop": "Success: 5",
    "mem_grow": "Success: 8192",
    "relop": "Success: 0",
    "return": "Success: 2",
    "unreachable": "Error",
}


def create_testfunc(tname, ext):
    testdir = os.path.abspath('tests')
    def func(*args):
        _self = args[0]
        tfile = os.path.join(testdir, "%s.%s" % (tname, ext))
        out = subprocess.check_output(['cargo', 'run', tfile], stderr=subprocess.DEVNULL).decode('UTF-8').strip()
        res = re.search(r'Success:.*', out, flags=re.DOTALL)
        if not res:
            res = re.search(r'Error:.*', out, flags=re.DOTALL)
        _self.assertIn(TESTS[tname], res.group(0))
    return func


def add_testfuncs(cls):
    for tpath in sorted(os.listdir('tests')):
        if '.wat' not in tpath: continue
        name, ext = tpath.split('.')
        setattr(cls, 'test_%s' % name, create_testfunc(name, ext))
    return cls


@add_testfuncs
class TestWAInterpreter(unittest.TestCase):
    pass


if __name__ == '__main__':
    unittest.main(verbosity=2, argv=sys.argv[:1])


