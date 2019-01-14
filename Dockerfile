FROM dragon7/carnd-extended-kalman-filter-project

# Install CarND-Kidnapped-Vehicle-Project
WORKDIR /root/workspace
RUN git clone https://github.com/udacity/CarND-Kidnapped-Vehicle-Project

# Copy solution code
WORKDIR /root/workspace/CarND-Kidnapped-Vehicle-Project
COPY src/particle_filter.cpp src/

WORKDIR /root/workspace
