NAME=hibp.bash
PASS_EXTENSION_DIR=/usr/lib/password-store/extensions
MAN_DIR=/usr/lib/share/man

all:
	@echo "Nothing to compile. run make install instead"

install:
	@install -v  "$(NAME)" "$(PASS_EXTENSION_DIR)/$(NAME)"

uninstall:
	@rm -vrf "$(PASS_EXTENSION_DIR)/$(NAME)"

.PHONY:
	install uninstall
