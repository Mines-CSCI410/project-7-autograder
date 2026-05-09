import unittest
import os
import subprocess

from gradescope_utils.autograder_utils.decorators import weight, number

class TestBase(unittest.TestCase): 
    def runStudentCode(self, name):
        try:
            process = subprocess.run(['./run_student_code.sh', f'{name}.vm'], check=True, text=True, capture_output=True, timeout=30)
            print(f'{process.stdout.strip()}\n{process.stderr.strip()}'.strip())
        except subprocess.CalledProcessError as err:
            error_message = str(err.stderr).strip()
            raise AssertionError(f'Unable to run student code on {name}.vm: "{error_message}"\n{err.stdout}'.strip())
        except subprocess.TimeoutExpired as err:
            raise TimeoutError(f'Student code timed out after {err.timeout} seconds:\n{str(err.stdout).strip()}')

    def assertValidAssembly(self, name):
        try:
            subprocess.run(['n2tAssembler', f'/autograder/source/{name}.asm'], check=True, text=True, capture_output=True, timeout=30)
        except subprocess.CalledProcessError as err:
            error_message = str(err.stderr).strip()
            raise AssertionError(f'Student\'s generated ASM is invalid, and could not be assembled: "{error_message}"\n{err.stdout}'.strip())
        except subprocess.TimeoutExpired as err:
            raise TimeoutError(f'Assembler timed out out after {err.timeout} seconds:\n{str(err.stdout).strip()}')

    def runCPUEmulator(self, name):
        try:
            subprocess.run(['n2tCPUEmulator', f'/autograder/source/{name}.tst'], check=True, text=True, capture_output=True, timeout=30)
        except subprocess.CalledProcessError as err:
            diff = subprocess.check_output(['/bin/sh', '-c', f'diff /autograder/source/{name}.cmp /autograder/source/{name}.out --strip-trailing-cr ; exit 0'], text=True)
            print(f'Files differ!\n{diff}')

            error_message = str(err.stderr).strip()
            raise AssertionError(f'Student\'s generated ASM did not pass the provided TST file: "{error_message}"\n{err.stdout}'.strip())
        except subprocess.TimeoutExpired as err:
            raise TimeoutError(f'Emulator timed out out after {err.timeout} seconds:\n{str(err.stdout).strip()}')

    def assertFileExists(self, path):
        if not os.path.isfile(path):
            raise AssertionError(f'File "{path}" does not exist!')

    def assertCorrectTranslator(self, name):
        self.runStudentCode(name)
        self.assertFileExists(f'/autograder/source/{name}.asm')
        self.assertValidAssembly(name)
        self.assertFileExists(f'/autograder/source/{name}.out')
        self.runCPUEmulator(name)

class TestModules(TestBase): 
    @weight(95/5)
    @number(1)
    def test_basic(self):
        self.assertCorrectTranslator('BasicTest')

    @weight(95/5)
    @number(2)
    def test_pointer(self):
        self.assertCorrectTranslator('PointerTest')

    @weight(95/5)
    @number(3)
    def test_stack(self):
        self.assertCorrectTranslator('StackTest')

    @weight(95/5)
    @number(4)
    def test_static(self):
        self.assertCorrectTranslator('StaticTest')

    @weight(95/5)
    @number(5)
    def test_simple_add(self):
        self.assertCorrectTranslator('SimpleAdd')
