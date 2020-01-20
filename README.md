# xmrig-scripts
Scripts to automate or manage xmrig. Written for my own personal use, see disclaimer before running. 

## Disclaimer
I assume no responsibility for any damage to your system from running these scripts. They are provided as-is in the hopes they are helpful, but they do not have robust error handling and you should review them before running.

They are tested on Ubuntu 16.04 and 18.04, and macOS 10.14. They generally follow the standard build instructions from the xmrig wiki and assume that all files will be cloned and located at ~/xmrig.

## How to Run
### `xmrig-update.sh` (install/build/update xmrig) 
1. Open a new terminal and create a new file using your favorite text editor (I'll use `nano` for simplicity):

    `$ nano xmrig-update.sh`
2. Copy and paste the full text of the script into the new text file, then press Control+O to save and Control+X to exit.
3. Make the new script executable:

    `$ chmod +x xmrig-update.sh`
4. Run the script:

    `$ ./xmrig-update.sh`

### `xmrig-auto.sh` (run xmrig with optimal number of threads for L3 cache/cores)
1. Open a new terminal and create a new file using your favorite text editor (I'll use `nano` for simplicity):

    `$ nano xmrig-auto.sh`
2. Copy and paste the full text of the script into the new text file, then press Control+O to save and Control+X to exit.
3. Make the new script executable:

    `$ chmod +x xmrig-auto.sh`

**Note:** This script assumes you have already built/installed xmrig to `~/xmrig/build/` and have a valid `config.json` file in that same directory. Make sure those exist before running `xmrig-auto.sh` or it will fail.

4. Run the script:

    `$ ./xmrig-auto.sh`
