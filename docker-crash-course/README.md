
## HOW TO BUILD THE DOCKERFILE

Building a fresh image.
- `docker build -t docker-ros .`
Initializing a bash inside the image (creating a container)

[INFO]: You can add `-p 4000:80` if you want to link ports to the container
- `docker run -it docker-ros /bin/bash`
