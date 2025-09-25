FROM amazonlinux:2

# Install dependencies: Apache, wget, unzip
RUN yum update -y && \
    yum install -y httpd wget unzip && \
    yum clean all

# Set working directory
WORKDIR /var/www/html

# Download and unzip web files # refernce from techmax demo site
RUN wget https://github.com/azeezsalu/techmax/archive/refs/heads/main.zip && \
    unzip main.zip && \
    cp -r techmax-main/* . && \
    rm -rf techmax-main main.zip

# Expose port 80
EXPOSE 80

# Start Apache in foreground
ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]
