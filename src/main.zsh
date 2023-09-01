() {
	local app_dir="${1:-.}"
	cd $app_dir || exit 1

	if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]]; then
		git init
		git branch --move me
	fi

	while true; do
		local contact="$(gum choose --limit 1 $(git branch --format='%(refname:short)'))"
		git checkout $contact
	done
} "$@"
