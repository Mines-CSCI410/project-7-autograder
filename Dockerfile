FROM gradescope/autograder-base:ubuntu-jammy-jdk17

# Install uv package manager
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Install packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get clean all -y
RUN apt-get update -y &&\
apt-get install -y\
    build-essential\
    cmake\
    gdb\
    dos2unix\
    neovim\
    golang\
    python3\
    python3-pip\
    git\
    python3-dev

WORKDIR /
ENV EXPECTED_HASH="b1c0900d2fd0211ae91f03d8680ba27b  -"
RUN git clone https://github.com/kishy-codes/nand2tetris.git
RUN test "$EXPECTED_HASH" = "$(git -C nand2tetris log -n 1 | md5sum)"
RUN chmod ug+x /nand2tetris/tools/*.sh
RUN ln -s /nand2tetris/tools/Assembler.sh /usr/bin/n2tAssembler 
RUN ln -s /nand2tetris/tools/HardwareSimulator.sh /usr/bin/n2tHardwareSimulator 
RUN ln -s /nand2tetris/tools/VMEmulator.sh /usr/bin/n2tVMEmulator 
RUN ln -s /nand2tetris/tools/CPUEmulator.sh /usr/bin/n2tCPUEmulator 
RUN ln -s /nand2tetris/tools/JackCompiler.sh /usr/bin/n2tJackCompiler 

WORKDIR /autograder/grader

# Install dependencies
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project

# Copy the project into the image
ADD . /autograder/grader
ADD run_autograder /autograder/run_autograder

# Sync the project
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked

# Setup unprivileged user
RUN adduser student --no-create-home --disabled-password --gecos ""

# Configure access to directories
RUN mkdir -p /autograder/submission
RUN mkdir -p /autograder/results
RUN mkdir /autograder/source

RUN chmod o= /autograder/grader
RUN chmod o= /autograder/submission
RUN chmod o= /autograder/results
RUN chmod -R ugo+rwx /autograder/source
