from setuptools import setup, Extension
from Cython.Build import cythonize

exts = [
    Extension("Fiasco", sources=["src/ecs_module.pyx"])
]

setup(
    name='Fiasco',
    ext_modules=cythonize(
      exts,
      language_level=3,
      annotate=True,
      show_all_warnings=True
    )
)
