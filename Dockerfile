# Use the official Tomcat 9 image with Java 11
FROM tomcat:9.0-jdk11-corretto

# Remove the default Tomcat welcome applications
RUN rm -rf /usr/local/tomcat/webapps/ROOT \
           /usr/local/tomcat/webapps/docs \
           /usr/local/tomcat/webapps/examples \
           /usr/local/tomcat/webapps/host-manager \
           /usr/local/tomcat/webapps/manager

# Bring in the un-built web app sources
WORKDIR /build
COPY src/        /build/src/
COPY web/        /build/web/

# Compile the servlet against Tomcat's servlet-api.jar
RUN javac -cp /usr/local/tomcat/lib/servlet-api.jar \
          -d /build/web/WEB-INF/classes \
          /build/src/attendance/Attend.java

# Package the web app as ROOT.war so it serves at the context root "/"
# (this makes https://attend95514.onrender.com/ directly reachable)
RUN jar -cvf /usr/local/tomcat/webapps/ROOT.war -C /build/web .

# Use an entry point that adapts the port to Render's PORT variable
COPY entrypoint.sh /usr/local/tomcat/bin/entrypoint.sh
RUN chmod +x /usr/local/tomcat/bin/entrypoint.sh

EXPOSE 8080
CMD ["/usr/local/tomcat/bin/entrypoint.sh"]
