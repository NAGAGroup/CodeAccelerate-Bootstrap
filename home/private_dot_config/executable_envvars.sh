if [ -z "$ENVVARS_SOURCED" ]; then
	export PATH=~/.pixi/bin:$PATH
	export PATH=~/bin:$PATH
	export PATH=~/.cargo/bin:$PATH
	export PATH=~/go/bin:$PATH

	export EDITOR=nvim
	export PATH=~/.local/bin:"$PATH"

	if [ -f ~/.config/extra_envvars.sh ]; then
		source ~/.config/extra_envvars.sh
	fi

#	if [ "$SHELL" != "fish" ]; then
#		exec ~/.pixi/bin/fish --interactive
#	fi
	export ENVVARS_SOURCED=1
fi
