# SD Card Real Capacity Tester

This script tests and recognizes the real capacity of an SD card, helping to detect fake SD cards that report a higher capacity than they actually have. It writes random data to the card, reads it back, and checks for mismatches to identify potential issues. The script also displays essential card details, including the serial number and UUID, to ensure that the correct device is being tested.

## Disclaimer

**WARNING**: 
1. This script will write directly to the selected partition.
2. This operation WILL OVERWRITE AND DESTROY ALL DATA on the partition.
3. After the test, the partition will be left in an unusable state and will require reformatting.
4. You will have to reformat the partition with the selected filesystem type after the test.
5. If you choose not to reformat, the partition will remain unusable until manually formatted.
6. Ensure you have backups of any important data before proceeding.
7. This script should only be used on devices you are willing to completely erase.

Additionally, the script will create a temporary file named `/tmp/sdcard_test_data` and a log file `/tmp/cmp_output`. 
If these files already exist, they will be overwritten. 
Please ensure you have backed up any important data before proceeding.
You can modify the paths for the test file and log file directly in the script if needed.

Use this script at your own risk. Ensure that you are testing the correct device to avoid accidental data loss.

---

## Features

- **Detect Fake SD Cards**: Identifies SD cards with falsely reported capacities by comparing written and read data.
- **Card Identification**: Displays key details such as the card's serial number, UUID, model, and vendor.
- **Progress Reporting**: Shows progress during both the writing and reading phases of the test.
- **User-Friendly**: Handles interruptions gracefully and provides clear feedback on the test's results.

## Requirements

- Bash (tested on Linux)
- `dd`, `lsblk`, `blkid`, `pv` and `udevadm` utilities

## Usage

1. **Clone the Repository**:
    ```bash
    git clone https://github.com/XClassicPeter/sdcardtest
    cd sdcardtest
    ```

2. **Run the Script**:
    ```bash
    sudo ./sdcardtest.sh /dev/sdX
    ```
    Replace `/dev/sdX` with the actual device path of your SD card (e.g., `/dev/sde1`).
   
    **Warning:** if you select a device (e.g., `/dev/sde`) not a partition (e.g., `/dev/sde1`) the script will erase a partition table and the data. You will have to restore the partition table manually.

4. **View Results**:
    The script will output the card details, progress during the test, and the estimated real capacity of the card. If a mismatch is detected, it will stop and provide details about the failure.

## Example Output

```bash
Card details for /dev/sde1:
sde1     59.6G SanDisk   Ultra
/dev/sde1: UUID="1234-ABCD" TYPE="vfat" PARTUUID="00000000-01"

Serial Number: 1234567890
UUID: 1234-ABCD

Reported capacity: 59 GB

Testing at offset: 0 bytes (0 MB)
Writing to device...
Reading back and comparing...
PASSED

Testing at offset: 4294967296 bytes (4096 MB)
Writing to device...
Reading back and comparing...
PASSED

...
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please fork this repository and submit a pull request with your improvements or bug fixes.

## Issues

If you encounter any problems, please create an issue on GitHub.

## Acknowledgments

Special thanks to the open-source community for providing the tools and utilities that made this project possible.
