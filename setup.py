

from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

import os
from sys import platform as _platform

if _platform == "linux" or _platform == "linux2":
    # linux
    pass

elif _platform == "darwin":
    os.environ["CC"]= "/usr/local/Cellar/gcc/5.2.0/bin/g++-5"
    os.environ["CXX"]= "/usr/local/Cellar/gcc/5.2.0/bin/g++-5"
    os.environ["ARCHFLAGS"]= "-arch x86_64"
    os.environ["MACOSX_DEPLOYMENT_TARGET"]= "10.10"

elif _platform == "win32":
    pass



extensions = [Extension(
    name="cppjieba", # the extesion name
    sources=["./jiebax/cppjieba.pyx", ], # the Cython source and additional C++ source files
    # "Jieba.hpp"
    language="c++", # generate and compile C++ code
    extra_compile_args=["-std=c++1y"],
)]


setup(name="jiebax", ext_modules=cythonize(extensions), 
    packages=['jiebax'],
    package_dir={'jiebax':'jiebax'},
    package_data={'jiebax':['*.*']}
)


# setup(ext_modules = cythonize(
#            "rect.pyx",                 # our Cython source
#            sources=["Rectangle.cpp"],  # additional source file(s)
#            language="c++",             # generate C++ code
#       ))


"""
dynamic lookup
=======================================================

g++ -bundle -undefined dynamic_lookup -L/Users/aaronyin/anaconda/lib -arch x86_64 -arch x86_64 build/temp.macosx-10.5-x86_64-2.7/rect.o build/temp.macosx-10.5-x86_64-2.7/Rectangle.o -L/Users/aaronyin/anaconda/lib -o /Users/aaronyin/TheCoverProject/JiebaX/jieba-cpp/rect_cython_test/rect.so

g++ -bundle -undefined dynamic_lookup -L/Users/aaronyin/anaconda/lib -arch x86_64 -arch x86_64 /Users/aaronyin/TheCoverProject/JiebaX/jieba-cpp/rect_cython_test/build/temp.macosx-10.5-x86_64-2.7/rect.o /Users/aaronyin/TheCoverProject/JiebaX/jieba-cpp/rect_cython_test/build/temp.macosx-10.5-x86_64-2.7/Rectangle.o -L/Users/aaronyin/anaconda/lib -o /Users/aaronyin/TheCoverProject/JiebaX/jieba-cpp/rect_cython_test/rect.so

"""



