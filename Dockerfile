# Pull base image
FROM resin/rpi-raspbian:latest

MAINTAINER Tobias Hargesheimer <docker@ison.ws>

# Install dependencies
RUN apt-get update && apt-get install -y \
	git \
	wget \
	openjdk-8-jre \
	openjdk-8-jdk \
	ca-certificates-java \
	--no-install-recommends && \
	rm -rf /var/lib/apt/lists/* && \
	/var/lib/dpkg/info/ca-certificates-java.postinst configure

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-armhf
# Repository 
ENV REPOSITORY https://github.com/TobiasH87/PRIVATE.telefonwahnsinn
ENV REPOSITORY_M2_WRAPPER_PROPERTIES https://raw.githubusercontent.com/TobiasH87/docker/master/rpi-phonemadness/maven-wrapper.properties

# Build Java Application 
RUN git clone ${REPOSITORY} PhoneMadness/ \
	&& cd PhoneMadness/ \
	&& chmod +x mvnw \
	&& cd maven && rm maven-wrapper.properties && wget ${REPOSITORY_M2_WRAPPER_PROPERTIES} -O maven-wrapper.properties && sed -i -e 's/https/http/g' maven-wrapper.properties && cd .. \
	&& ./mvnw clean package \
	&& cp target/TelefonWahnsinn-jar-with-dependencies.jar /TelefonWahnsinn.jar \
	&& mkdir /config && cp config/config.xml.example /config/config.xml \
	&& cd .. && rm -r PhoneMadness/ 

# Define Volumes
VOLUME ["/config","/sys/class/gpio"]

# Define default command
CMD ["java","-jar","/TelefonWahnsinn.jar"]
