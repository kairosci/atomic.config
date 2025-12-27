delete_folders() {
    read -p "Folder: " folder_name
    [ -z "$folder_name" ] && {
      return 1;
    }

    sudo find / -type d -name "*$folder_name*" -exec rm -r {} + 2> /dev/null
    echo "Done."
}

delete_folders
