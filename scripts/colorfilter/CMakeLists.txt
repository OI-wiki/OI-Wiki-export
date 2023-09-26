cmake_minimum_required (VERSION 3.8)

project ("OI WIKI Color Filter")

find_package(OpenCV REQUIRED)
# opencv include path: /opt/opencv

include_directories(${OpenCV_INCLUDE_DIRS})
link_libraries(${OpenCV_LIBS})

add_executable (colorfilter "main.cpp")
