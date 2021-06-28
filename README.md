# CSE Installation Script

Use this repo to download the appropriate script to the host.

# Pull the latest version of the script

This command will pull down the latest tagged version of the CSE Installation script to help configure Virtru CSE

```
curl -s https://api.github.com/repos/virtru/cse-install-script/releases/latest \
| grep "browser_download_url.*sh" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -
```

Execute the script to build you CSE directories and run script.