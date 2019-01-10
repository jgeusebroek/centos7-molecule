FROM centos:7
MAINTAINER Jeroen Geusebroek <me@jeroengeusebroek.nl>

RUN yum makecache fast && yum update -y \
    && yum install -y python sudo yum-plugin-ovl bash \
    && sed -i 's/plugins=0/plugins=1/g' /etc/yum.conf \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && yum clean all \
    && cp /bin/true /sbin/agetty

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
	systemd-tmpfiles-setup.service ] || rm -f $i; done); \
	rm -f /lib/systemd/system/multi-user.target.wants/*;\
	rm -f /etc/systemd/system/*.wants/*;\
	rm -f /lib/systemd/system/local-fs.target.wants/*; \
	rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
	rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
	rm -f /lib/systemd/system/basic.target.wants/*;\
	rm -f /lib/systemd/system/anaconda.target.wants/*;

# Epel is required for python-pip
RUN yum install -y epel-release  \
    && yum update -y \
    && yum install python-pip python-devel @development -y \
    && pip install --upgrade pip setuptools

RUN pip install ansible molecule \
    && yum clean all

RUN mkdir -p /etc/ansible

RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]