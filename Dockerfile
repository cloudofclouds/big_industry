# Use an official Tomcat base image
FROM tomcat:9.0

# Set environment variables
ENV JAVA_OPTS="-Djava.awt.headless=true"

# Copy the WAR file to the Tomcat webapps directory
COPY target/ABCtechnologies-1.0.war /usr/local/tomcat/webapps/

# Expose the default Tomcat port
EXPOSE 8080

# Start Tomcat server
CMD ["catalina.sh", "run"]