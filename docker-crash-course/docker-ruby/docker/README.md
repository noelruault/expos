# README

> !! This dockerized environment is stil on beta, so you will find a lot of commented code that can in return show some of the ideas that have emerged during the development process.

**Ruby version** 2.3.1

**System dependencies**

**Configuration**
- Exposing the ip of the servers to `0.0.0.0` is needed.
- Exposing ports is needed in run command (`run -p 3000:3000`).

**Database creation and population**
!! Populate database is still not made, it is required to be done manually.

**Database initialization**
The script create_db located in /mnt/docker/scripts needs to be executed
when you initialize a container. It's configured as entrypoint in Dockerfile but
if you notice any error related with servers related to the app or the database
check and rerun this file if needed.
`/mnt/docker/scripts/create_db.sh`

**Services (job queues, cache servers, search engines, etc.)**

- redis
- mysql

**Deployment instructions**

How to build MM app dockerized beta
```sh
docker build -t qvantel/masmovil-base .
docker run -itd -v $(pwd):/mnt -p 3000:3000 --name container0 -it qvantel/masmovil-base /bin/bash
```

After that you will be able to start any app that you want.
If you want to start multiple applications, you can do it initializing multiple
containers and exposing different ports. Like this:
```sh
docker run -itd -v $(pwd):/mnt -p 4000:3000 --name container1 -it qvantel/masmovil-base /bin/bash
```

> After that, you can start for example newton.
> `cd /mnt/newton && bundle exec rails server -b 0.0.0.0`

```sh
docker run -itd -v $(pwd):/mnt -p 5000:3000 --name container2 -it qvantel/masmovil-base /bin/bash
```

> `cd /mnt/selforder && bundle exec rails server -b 0.0.0.0`

So in result you will have available `localhost:4000` and `localhost:5000`
in your host machine.

**TO-DO**:
- Database as independent container.
- Script to download dump from database and execute the dump.
- Test suite
