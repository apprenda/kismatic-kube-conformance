KUBERNETES_VERSION=v1.5.3
GOOS=$(shell go env GOOS)
KET_LINK=https://kismatic-installer.s3-accelerate.amazonaws.com/latest/kismatic.tar.gz

ifeq ($(GOOS), darwin)
	KET_LINK = https://kismatic-installer.s3-accelerate.amazonaws.com/latest-darwin/kismatic.tar.gz
endif

run-conformance: build-cluster kubernetes build-tests kubectl ginkgo
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
	cd kubernetes && git checkout $(KUBERNETES_VERSION)

build-tests:
	cd kubernetes && make WHAT=test/e2e/e2e.test

kubectl:
	cd kubernetes && make WHAT=cmd/kubectl

ginkgo:
	go get github.com/onsi/ginkgo/ginkgo
	mkdir -p kubernetes/_output/bin
	cp $(shell go env GOPATH)/bin/ginkgo/ kubernetes/_output/bin/ginkgo

clean-kubernetes:
	rm -rf kubernetes

clean: clean-kismatic clean-kubernetes
