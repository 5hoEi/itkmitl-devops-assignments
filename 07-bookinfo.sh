#!/bin/sh
mkdir all-service
cd all-service/
git clone -b dev git@github.com:5hoEi/itkmitl-bookinfo-ratings.git ~/all-service/ratings
git clone -b dev git@github.com:5hoEi/itkmitl-bookinfo-details.git ~/all-service/details
git clone -b dev git@github.com:5hoEi/itkmitl-bookinfo-reviews.git ~/all-service/reviews
git clone -b dev git@github.com:5hoEi/itkmitl-bookinfo-productpage.git ~/all-service/productpage

docker build -t ratings ~/all-service/ratings
docker build -t details ~/all-service/details
docker build -t reviews ~/all-service/reviews
docker build -t productpage ~/all-service/productpage
docker run -d --name mongodb -p 27017:27017 -v ~/all-service/ratings/databases:/docker-entrypoint-initdb.d bitnami/mongodb:5.0.2-debian-10-r2
docker run -d --name ratings -p 8080:8080 --link mongodb:mongodb -e SERVICE_VERSION=v2 -e 'MONGO_DB_URL=mongodb://mongodb:27017/ratings' ratings
docker run -d --name details -p 8081:8081 details
docker run -d --name reviews -p 8082:9080 --link ratings:ratings -e 'RATINGS_SERVICE=http://ratings:8080' -e 'ENABLE_RATINGS=true' reviews
docker run -d --name productpage -p 8083:8083 --link details:details --link ratings:ratings --link reviews:reviews -e 'REVIEWS_HOSTNAME=http://reviews:9080' -e 'RATINGS_HOSTNAME=http://ratings:8080' -e 'DETAILS_HOSTNAME=http://details:8081' productpage