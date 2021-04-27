SUDO				:= sudo
MOVE				:= mv
COPY				:= cp
SED					:= sed -i '.bkp'

PKG_MANAGER			:= apt-get
PKG_SOURCES_PATH	:= /etc/apt/sources.list
PKG_SOURCES_BCKP	:= /etc/apt/sources.list.bkp
PKG_UPDATE			:= $(SUDO) $(PKG_MANAGER) update
PKG_INSTALL			:= $(SUDO) $(PKG_MANAGER) install
DEV_UTILS			:= make build-essential libssl-dev zlib1g-dev libbz2-dev \
	libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils \
	tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

define succeed
	@echo "[ O K ]: $(0)"
endef

define error
	@echo "[Error]: $(0)"
endef

pkg-sources:
	@$(SUDO) $(COPY) $(PKG_SOURCES_PATH) $(PKG_SOURCES_BCKP)
	@$(SUDO) $(SED)  's/\/\/.*\/ubuntu\//\/\/mirrors.tuna.tsinghua.edu.cn\/ubuntu\//' $(PKG_SOURCES_PATH)
	@$(PKG_UPDATE)
	@$(succeed "Package manager source changed")

DEV_UTILS: pkg-sources


network:
	@export http_proxy=http://127.0.0.1:7890
	@export https_proxy=http://127.0.0.1:7890

zsh: apt-source
	sudo apt install zsh

ohmyzsh: zsh, curl, network
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

hello:
	@echo $(text)

clean:
	@$(SUDO) $(MOVE) $(PKG_SOURCES_BCKP) $(PKG_SOURCES_PATH)
