FROM public.ecr.aws/amazonlinux/amazonlinux:2.0.20230404.0-arm64v8
RUN yum update -y \
    && amazon-linux-extras install nginx1 -y \
    && yum install install nginx-mod-stream -y \
    && yum install net-tools -y \
    && yum install iputils -y \
    && yum install procps -y \
    && yum install htop -y \
    && mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
COPY nginx.conf /etc/nginx/
COPY ipcontrol.conf /etc/nginx
RUN ln -sf /dev/stdout /var/log/nginx/http_access.log \
    && ln -sf /dev/stderr /var/log/nginx/http_error.log \
	&& ln -sf /dev/stdout /var/log/nginx/stream_access.log \
    && ln -sf /dev/stderr /var/log/nginx/stream_error.log
CMD ["nginx", "-g", "daemon off;"]