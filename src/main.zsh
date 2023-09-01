() {
	local app_dir="${1:-.}"
	cd $app_dir || exit 1

	if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]]; then
		git init
		git branch --move me
		git commit --allow-empty --message 'Start talking here...'
	fi

	while true; do
		local action="$(echo 'PWD\nWrite\nMessages\nContacts\nPull\nEXIT' | gum filter)"
		case "$action" in
			PWD)
				gum confirm "$(pwd)"
				;;
			Write)
				git commit --allow-empty --message "$(gum write --placeholder "What do you want to say? (CTRL+D to finish)")"
				;;
			Messages)
				git log --format='%H' | fzf --preview 'git show {}'
				;;
			Contacts)
				local contact="$(gum choose --limit 1 $(git branch --format='%(refname:short)'))"
				git checkout $contact
				;;
			Pull)
				gum spin --title "Pulling..." -- git pull --rebase "$(git branch --show-current)"
				;;
			EXIT)
				exit 0
				;;
			*)
				;;
		esac
	done
} "$@"
