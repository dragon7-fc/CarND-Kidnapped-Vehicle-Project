# **Prticle Filter**

[//]: # (Image References)

[image1]: ./images/demo.gif "demo"
[image2]: ./images/import.jpg "import"
[image3]: ./images/existing_project.jpg "existing project"
[image4]: ./images/select_project.png "select project"
[image5]: ./images/final.png "final"
[image6]: ./images/build_all.png "build all"
[image7]: ./images/run_as.png "run as"
[image8]: ./images/simulator.png "simulator"
[image9]: ./images/flowchart.png "flowchart"
[image10]: ./images/gaussian.png "Gaussian Distribution"
[image11]: ./images/yaw_zero.png "yaw zero"
[image12]: ./images/yaw_not_zero.png "yaw not zero"
[image13]: ./images/map.png "map"
[image14]: ./images/homogenous.png "homogenous"
[image15]: ./images/multivariate_gaussian.png "Multivariate Gaussian"
[image16]: ./images/resample.png "resample"
[image17]: ./images/result.png "result"

**Prticle Filter Project**

Your robot has been kidnapped and transported to a new location! Luckily it has a map of this location, a (noisy) GPS estimate of its initial location, and lots of (noisy) sensor and control data.

In this project you will implement a 2 dimensional particle filter in C++. Your particle filter will be given a map and some initial localization information (analogous to what a GPS would provide). At each time step your filter will also get observation and control data.

![alt text][image1]

## Simulator behavior

The program main.cpp has already been filled out, but feel free to modify it.

Here is the main protocol that main.cpp uses for uWebSocketIO in communicating with the simulator.

INPUT: values provided by the simulator to the c++ program

// sense noisy position data from the simulator

["sense_x"]

["sense_y"]

["sense_theta"]

// get the previous velocity and yaw rate to predict the particle's transitioned state

["previous_velocity"]

["previous_yawrate"]

// receive noisy observation data from the simulator, in a respective list of x/y values

["sense_observations_x"]

["sense_observations_y"]


OUTPUT: values provided by the c++ program to the simulator

// best particle values used for calculating the error evaluation

["best_particle_x"]

["best_particle_y"]

["best_particle_theta"]

//Optional message data used for debugging particle's sensing and associations

// for respective (x,y) sensed positions ID label

["best_particle_associations"]

// for respective (x,y) sensed positions

["best_particle_sense_x"] <= list of sensed x positions

["best_particle_sense_y"] <= list of sensed y positions


Your job is to build out the methods in `particle_filter.cpp` until the simulator output says:

```
Success! Your particle filter passed!
```

# Implementing the Particle Filter
The directory structure of this repository is as follows:

```
root
|   build.sh
|   clean.sh
|   CMakeLists.txt
|   README.md
|   run.sh
|
|___data
|   |   
|   |   map_data.txt
|   
|   
|___src
    |   helper_functions.h
    |   main.cpp
    |   map.h
    |   particle_filter.cpp
    |   particle_filter.h
```

The only file you should modify is `particle_filter.cpp` in the `src` directory. The file contains the scaffolding of a `ParticleFilter` class and some associated methods. Read through the code, the comments, and the header file `particle_filter.h` to get a sense for what this code is expected to do.

If you are interested, take a look at `src/main.cpp` as well. This file contains the code that will actually be running your particle filter and calling the associated methods.

## Inputs to the Particle Filter
You can find the inputs to the particle filter in the `data` directory.

#### The Map*
`map_data.txt` includes the position of landmarks (in meters) on an arbitrary Cartesian coordinate system. Each row has three columns
1. x position
2. y position
3. landmark id

### All other data the simulator provides, such as observations and controls.

> * Map data provided by 3D Mapping Solutions GmbH.

---
## Dependencies

* [simulator](https://github.com/udacity/self-driving-car-sim/releases)

## Environment Setup

1. Open Eclipse IDE

__Linux__:
```
docker run --rm --name kidnap \
    --net=host -e DISPLAY=$DISPLAY \
    -v $HOME/.Xauthority:/root/.Xauthority \
    dragon7/carnd-kidnapped-vehicle-project
```

__Mac__:
```
socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\"

docker run --rm --name kidnap \
    -e DISPLAY=[IP_ADDRESS]:0 \
    -p 4567:4567 \
    dragon7/carnd-kidnapped-vehicle-project
```

2. Import the project into Eclipse

    1. Open Eclipse.
    2. Import project using Menu `File > Import`
    ![alt text][image2]
    3. Select `General > Existing projects into workspace`
    ![alt text][image3]
    4. **Browse** `/root/workspace/CarND-Kidnapped-Vehicle-Project/build` and select the root build 
    tree directory. Keep "Copy projects into workspace" unchecked.
    ![alt text][image4]
    5. Now you should have a fully functional eclipse project
    ![alt text][image5]

3. Code Style

    1. From Eclipse go to `Window > Preferences > C/C++ > Code Style > Formatter`
    2. Click Import
    3. Select `/root/workspace/eclipse-cpp-google-style.xml`
    4. Click Ok

4. Build

    * Select `Project -> Build All`
    ![alt text][image6]

    __OPTIONAL__: Build on command line
    ```
    cd /root/workspace/CarND-Kidnapped-Vehicle-Project/build
    make
    ```

5. Run

    * `Right click Project -> Run as -> 1 Local C++ Application`
    ![alt text][image7]

    __OPTIONAL__: Run on command line
    
    `/particle_filter`


6. Launch simulator

    ![alt text][image8]

---
## Particle Filter General Flow

![alt text][image9]

### Initialization

* Set the number of particles.
```c++
num_particles = 100;
```
* Initialize all particles to first position (based on estimates of x, y, theta and their uncertainties from GPS) and all weights to 1. 
* Add random Gaussian noise to each particle.

![alt text][image10]

__NOTE__: When adding noise you may find `std::normal_distribution` and `std::default_random_engine` useful.

### Prediction Step

* Add measurements to each particle and add random Gaussian noise.

| Yaw reate = 0        | Yaw rate != 0        |
|----------------------|----------------------|
| ![alt text][image11] | ![alt text][image12] |

__NOTE__: Here we will use what we learned in the motion models lesson to predict where the vehicle will be at the next time step, by updating based on yaw rate and velocity, while accounting for Gaussian sensor noise.

### Update Step

* Update the weights of each particle using a mult-variate Gaussian distribution. 

    1. Transform observations from vehicle coordinates to map coordinates.

    ![alt text][image13]

    ![alt text][image14]

    __NOTE__: The observations are given in the VEHICLE'S coordinate system. Your particles are located according to the MAP'S coordinate system. You will need to transform between the two systems. Keep in mind that this transformation requires both rotation AND translation (but no scaling).

    2. Filter map landmarks to keep only those which are in the sensor_range of current 
     particle. Push them to predictions vector.

    3. Associate observations to predicted landmarks using nearest neighbor algorithm.

    __NOTE__: Find the predicted measurement that is closest to each observed measurement and assign the observed measurement to this particular landmark.

    4. Calculate the weight of each particle using Multivariate Gaussian distribution.

    ![alt text][image15]

    5. Normalize the weights of all particles since resampling using probabilistic approach.



### Resample

* Resample particles with replacement with probability proportional to their weight. 

![alt text][image16]

---
## Result

![alt text][image17]
