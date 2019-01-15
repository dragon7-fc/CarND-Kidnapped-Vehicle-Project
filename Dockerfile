FROM dragon7/carnd-extended-kalman-filter-project

# Install CarND-Kidnapped-Vehicle-Project
WORKDIR /root/workspace
COPY ./ CarND-Kidnapped-Vehicle-Project/

# Create Eclipse IDE project
WORKDIR /root/workspace/CarND-Kidnapped-Vehicle-Project
RUN mkdir build
RUN mv CMakeLists.txt src
RUN sed -i 's/src/./g' src/CMakeLists.txt
WORKDIR /root/workspace/CarND-Kidnapped-Vehicle-Project/build
RUN cmake -G"Eclipse CDT4 - Unix Makefiles" -D CMAKE_BUILD_TYPE=Debug ../src/
RUN make

WORKDIR /root/workspace
