test:
	@echo Running RedCache test suite
	@for i in $$(ls -1 tests/*_test.rb); do echo "==== " $$i " ===="; ruby -Ilib:tests $$i;done

cli:
	@ruby -Ilib redcache_cli.rb