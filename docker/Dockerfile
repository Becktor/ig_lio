# Use official ROS 2 Jazzy image as the base
FROM ros:jazzy-perception

ARG PACKAGE_NAME=iglio
ARG CONTAINER_NAME=naisr_iglio

# Set non-interactive frontend to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Tweak APT configuration
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    # Don't install recommended pkgs
    echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > \
    /etc/apt/apt.conf.d/01norecommend \
    # Assume `-y`
    && echo 'APT::Get::Assume-Yes "true";' > \
    /etc/apt/apt.conf.d/02assumeyes \
    # Keep APT package cache
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' \
    > /etc/apt/apt.conf.d/03keep-cache \
    && echo 'APT::Clean-Installed "false";' \
    > /etc/apt/apt.conf.d/04clean-installed-off \
    && rm -f /etc/apt/apt.conf.d/docker-clean

# Add string to shell prompt to help identify Docker container shells
RUN echo ${PACKAGE_NAME} > /etc/debian_chroot
# Install additional build tools and dependencies
RUN apt-get update && apt-get install -y \
    git \
    vim \
    tmux \
    tmuxp \
    htop \
    python3-colcon-common-extensions \
    python3-colcon-clean \
    python3-rosdep \
    python3-vcstool \
    ros-jazzy-rviz2 \
    ros-jazzy-rqt* \
    libgoogle-glog-dev \
    && rm -rf /var/lib/apt/lists/*

# Ensure rosdep is initialized (should already be in the base image, but just in case)
RUN rosdep update

# Set up workspace
WORKDIR /naisr2_ws
RUN mkdir -p /naisr2_ws/src

# Copy the DLIO repo from the parent folder (build context) into the workspace
COPY . /naisr2_ws/src/ig_lio

# Install ROS dependencies with APT cache
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    /bin/bash -c "source /opt/ros/jazzy/setup.bash && \
    rosdep install --from-paths src --ignore-src -r -y"

# install deps
#RUN git clone https://github.com/zijiechenrobotics/ig_lio_workspace.git /naisr2_ws/src/ig_lio_workspace
#RUN git clone https://github.com/Livox-SDK/livox_ros_driver /naisr2_ws/src/livox_ros_driver

# Build the workspace with colcon cache
# RUN --mount=type=cache,target=/naisr2_ws/build,sharing=locked \
#     /bin/bash -c "source /opt/ros/jazzy/setup.bash && \
#     colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo"

# clear the workspace since we will mount it as a volume
RUN rm -rf /naisr2_ws/src/ig_lio

RUN echo "colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo" >> /naisr2_ws/build_ws.sh

# setup environment
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# create with

ARG USERNAME=jobe
RUN groupadd ${USERNAME} && \
    useradd -m -g ${USERNAME} -s /bin/bash ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}

# Copy and set the entrypoint from the dlio-docker subdirectory
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
USER ${USERNAME}
RUN echo "source /opt/ros/jazzy/setup.bash" >> /home/${USERNAME}/.bashrc
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]