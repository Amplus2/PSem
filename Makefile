all: update

update: ../collatz-collection
	make -C "../collatz-collection" dist
	cp -rf ../collatz-collection/dist/* .
