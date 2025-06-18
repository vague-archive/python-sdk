#include <stdio.h>
#include <dlfcn.h>
#include "ecs_module.h"

// Relative paths, starting from where the engine (platform_native) exe is running
#define PROJECT_PATH "src"
#define PACKAGES_PATH ".venv/lib/python3.12/site-packages"

// void_target_version is the first FFI function called
// by the engine, we wrap the python version of it so
// we can initialize the python interpreter and our cython module
// before the rest of the FFI functions are called.
int void_target_version() {
    printf("void_target_version called in fiasco.c\n");

    if (PyImport_AppendInittab("Fiasco", PyInit_Fiasco) == -1) {
        fprintf(stderr, "Failed to append Fiasco to inittab\n");
        return 1;
    }

    Py_Initialize();

    // Update the path so python can find and resolve
    // local import statements inside the .py/.pyx files.
    // This is like `sys.path.append("...")` in python.
    PyObject *path = PySys_GetObject("path");
    PyObject *project_path = PyUnicode_FromString(PROJECT_PATH);
    if (PyList_Append(path, project_path) != 0) {
        fprintf(stderr, "Failed to update path with PROJECT_PATH\n");
        return -1;
    }

    PyObject *packages_path = PyUnicode_FromString(PACKAGES_PATH);
    if (PyList_Append(path, packages_path) != 0) {
        fprintf(stderr, "Failed to update path with PACKAGES_PATH\n");
        return -1;
    }

    PyObject *fiasco = PyImport_ImportModule("Fiasco");
    if (!fiasco) {
        PyErr_Print();
        fprintf(stderr, "Failed to import Fiasco\n");
        return -1;
    }

    // Call the cython version to get the real value
    int version = void_target_version2();
    printf("Response from void_target_version2 is: %d\n", version);

    // Py_Finalize(); // This might be needed at some point

    return version;
}
