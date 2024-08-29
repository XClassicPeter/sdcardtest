# SD Card Real Capacity Tester

This script tests and recognizes the real capacity of an SD card, helping to detect fake SD cards that report a higher capacity than they actually have. It writes random data to the card, reads it back, and checks for mismatches to identify potential issues. The script also displays essential card details, including the serial number and UUID, to ensure that the correct device is being tested.

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

3. **View Results**:
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

## Disclaimer: Use this script at your own risk. Ensure that you are testing the correct device to avoid accidental data loss.
