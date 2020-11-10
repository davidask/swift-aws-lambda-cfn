FROM swift:5.3-amazonlinux2
  
RUN yum -y install zip glibc wget python-pip
RUN pip install --user cfn-lint
