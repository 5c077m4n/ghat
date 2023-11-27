() {
	local app_dir="${1:-.}"
	cd $app_dir || exit 1

	gum style --border double --align center --width 50 --margin "1 2" --padding "2 4" 'Git cHAT'

	if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]]; then
		git init
		git branch --move me
		git commit --allow-empty --message '---- Conversation Start ----'
	fi

	while true; do
		local action="$(echo 'Write\nMessages\nReword\nContacts\nNewContact\nPull\nEXIT' | gum filter)"
		case "$action" in
			Write)
				local commit_msg="$(gum write --placeholder "What do you want to say? (CTRL+D to finish)")"
					git commit --allow-empty --message "$commit_msg"
					;;
				Messages)
					git log --format='%h' | fzf --preview 'git show {}'
					;;
				Reword)
					local msg_hash="$(git log --format='%H' | fzf --preview 'git show {}')"

					git commit --fixup="reword:$msg_hash" --allow-empty
					git rebase --autostash --autosquash --interactive "${msg_hash}^"
					;;
				Contacts)
					local contact="$(git branch --format='%(refname:short)' | gum filter)"
					git checkout "$contact"
					;;
				NewContact)
					local contact="$(gum input --placeholder "New contact's name")"
					git checkout -b "$contact"
					;;
				Pull)
					gum spin --title "Pulling..." -- git pull --rebase origin "$(git branch --show-current)"
					;;
				EXIT)
					exit 0
					;;
				*)
					exit 1
					;;
			esac
		done
	} "$@"
