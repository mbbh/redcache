test:
	@echo Running RedCache test suite
	@for i in $$(ls -1 tests); do echo "==== " tests/$$i " ==="; ruby tests/$$i;done

cli:
	@ruby redcache_cli.rb