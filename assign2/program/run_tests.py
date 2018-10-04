import os
import sys
import unittest
import subprocess
import re

# RUN FROM assign2/solution

TESTS = {
    "binop1": "Success: (Int 10)",
    "binop2": "Success: (Int -25)",
    "binop3": "Success: (Int -8)",
    "binop_fail1": "Error",
    "binop_fail2": "Error",
    "binop_zero1": "Success: (Int 0)",
    "case1": "Success: (Int 9)",
    "case_fail1": "Error",
    "function_apply1": "Success: (Int 140)",
    "function_apply2": "Success: (Int 15)",
    "function_apply_error1": "Error",
    "function_error1": "Error",
    "function_type1": "Success: (Lam x (Fn Int Int) (Binop Add (Int 3) (App (Var x) (Int 7))))",
    "function_type2": "Success: (Lam sup (Fn Int (Fn Int Int)) (Int 3))",
    "function_type3": "Success: (Int 1337)",
    "inject1": "Success: (Inject (Int 1) Left (Sum Int (Product Int Int)))",
    "inject2": "Success: (Inject (Pair (Int 4) (Int 5)) Right (Sum Int (Product Int Int)))",
    "inject_fail1": "Error",
    "pair1": "Success: (Pair (Int 5) (Int 2))",
    "pair2": "Success: (Int 9)",
    "pair_fail1": "Error",
    "project1": "Success: (Lam x (Product Int Int) (Project (Var x) Left))",
    "project_fail1": "Error",
    "simple_fail1": "Error",
    "simple_fail2": "Error",
    "binop_zero_adv1": "(Int 0)",
    "case_adv1": "Success: (Lam y Int (Binop Add (Int 3) (Var y)))",
    "function_apply_adv1": "Success: (Int 34)",
    "function_apply_adv2": "Success: (Int 240)",
    "function_apply_error2": "Error",
    "function_error2": "Error",
    "function_error_advanced1": "Error",
    "function_lexical_error1": "Error",
    "function_variable_apply1": "Success",
    "inject_adv1": "Success: (Inject (Pair (Int 3) (Lam x Int (Var x))) Right\n (Sum Int (Product Int (Fn Int Int))))",
    "pair_adv1": "Success: (Int 20)",
    "pair_adv2": "Success: (Inject (Int 5) Right (Sum Int Int))",
    "pair_fail_adv1": "Error"
}


def create_testfunc(tname, ext):
    testdir = os.path.abspath('tests')
    def func(*args):
        _self = args[0]
        tfile = os.path.join(testdir, "%s.%s" % (tname, ext))
        out = subprocess.check_output(['./main.native', tfile]).decode('UTF-8').strip()
        res = re.search(r'Success:.*', out, flags=re.DOTALL)
        if not res:
            res = re.search(r'Error:.*', out, flags=re.DOTALL)
        _self.assertIn(TESTS[tname], res.group(0))
    return func


def add_basic_testfuncs(cls):
    for tpath in sorted(os.listdir('tests')):
        if '.lam1' not in tpath: continue
        name, ext = tpath.split('.')
        setattr(cls, 'test_%s' % name, create_testfunc(name, ext))
    return cls


def add_adt_testfuncs(cls):
    for tpath in sorted(os.listdir('tests')):
        if '.lam2' not in tpath: continue
        name, ext = tpath.split('.')
        setattr(cls, 'test_%s' % name, create_testfunc(name, ext))
    return cls


@add_basic_testfuncs
class TestBasicLambdaInterpreter(unittest.TestCase):
    pass


@unittest.skipIf(len(sys.argv) < 2, 'ADTs test')
@add_adt_testfuncs
class TestADTLambdaInterpreter(unittest.TestCase):
    pass


if __name__ == '__main__':
    unittest.main(verbosity=2, argv=sys.argv[:1])
