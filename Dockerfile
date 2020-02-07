# Copyright (c) 2019 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

FROM alpine:3.10.2

# odo and oc versions have to match the ones defined in https://github.com/redhat-developer/vscode-openshift-tools/blob/master/src/tools.json
ENV GLIBC_VERSION="2.30-r0" \
    ODO_VERSION="v1.1.0" \
    OC_VERSION="3.11.170" \
    KUBECTL_VERSION="v1.17.2" \
    HOME="/home/theia"

RUN mkdir /projects ${HOME} && \
    # Change permissions to let any arbitrary user
    for f in "${HOME}" "/etc/passwd" "/projects"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done

# plugin executes the commands relying on Bash
RUN apk add --update --no-cache bash && \
    # install glibc compatibility layer package for Alpine Linux
    # see https://github.com/openshift/origin/issues/18942 for the details
    wget -O glibc-${GLIBC_VERSION}.apk https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
    apk --update --allow-untrusted add glibc-${GLIBC_VERSION}.apk && \
    rm -f glibc-${GLIBC_VERSION}.apk && \
    # get oc
    wget -O - https://mirror.openshift.com/pub/openshift-v3/clients/${OC_VERSION}/linux/oc.tar.gz | tar -xz oc -C /usr/local/bin && \ 
    # get odo
    wget -O /usr/local/bin/odo https://mirror.openshift.com/pub/openshift-v4/clients/odo/${ODO_VERSION}/odo-linux-amd64 && \
    # get kubectl
    wget -O /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    # fix perms
    chmod +x /usr/local/bin/oc /usr/local/bin/odo /usr/local/bin/kubectl

ADD etc/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ${PLUGIN_REMOTE_ENDPOINT_EXECUTABLE}
