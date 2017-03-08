KUBERNETES_VERSION=v1.5.3
GOOS=$(shell go env GOOS)
GOPATH=$(shell go env GOPATH)
KUBERNETES_SRC=$(GOPATH)/src/k8s.io/kubernetes
KET_LINK=https://kismatic-installer.s3-accelerate.amazonaws.com/latest/kismatic.tar.gz

ifeq ($(GOOS), darwin)
	KET_LINK = https://kismatic-installer.s3-accelerate.amazonaws.com/latest-darwin/kismatic.tar.gz
endif

run-conformance: kubernetes build-tests kubectl ginkgo build-cluster
	./run-conformance.sh

build-cluster: kismatic
	cd kismatic && \
		./provision aws create -e 1 -m 1 -w 4 && \
		./kismatic install apply --verbose

kismatic: 
	mkdir -p kismatic
	curl -O -L $(KET_LINK)
	tar -xf kismatic.tar.gz -C kismatic
	rm kismatic.tar.gz

clean-kismatic:
	rm -rf kismatic

kubernetes:
	git clone https://github.com/kubernetes/kubernetes
	mkdir -p $(GOPATH)/src/k8s.io
	mv kubernetes $(KUBERNETES_SRC)
	cd $(KUBERNETES_SRC) && git checkout $(KUBERNETES_VERSION)

build-tests:
	cd $(KUBERNETES_SRC) && make WHAT=test/e2e/e2e.test

kubectl:
	cd $(KUBERNETES_SRC) && make WHAT=cmd/kubectl

ginkgo:
	go get github.com/onsi/ginkgo/ginkgo
	mkdir -p $(KUBERNETES_SRC)/_output/bin
	cp $(shell go env GOPATH)/bin/ginkgo $(KUBERNETES_SRC)/_output/bin/ginkgo

clean: clean-kismatic
