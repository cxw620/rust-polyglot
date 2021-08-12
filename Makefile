
SPHINXBUILD	?= sphinx-build

default: doc

doc:	docs/html/index.html
	@echo 'Documentation can now be found here:'
	@echo '  file://$(PWD)/$<'

docs/html/index.html: docs/conf.py $(wildcard docs/*.md docs/*.rst docs/*.png)
	$(SPHINXBUILD) -M html docs docs $(SPHINXOPTS)
