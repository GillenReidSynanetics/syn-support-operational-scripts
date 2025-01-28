$mainmenu = {
    Write-Host "***************"
    Write-Host "SSL Management Menu"
    Write-Host 
    Write-Host "1. Encrypt"  # Option to run the backup script
    Write-Host "2. Decrypt"  # Option to run the validation script
    Write-Host "3. Inventory Reporter"  # Option to to sample local docker enviroment (Not tested yet)
    Write-Host "4. Reboot Container (Not tested yet)"  # Option to reboot the container
    Write-Host "5. Exit"  # Option to exit the script
    Write-Host "Select option and press enter"
}

& $mainmenu  # Display the menu

# Function to encrypt or decrypt text using Caesar Cipher
function Convert-CaesarCipher {
    param (
        [string]$Text,    # Text to encrypt or decrypt
        [int]$Shift,      # Number of positions to shift
        [switch]$Decrypt  # Switch for decryption
    )

    # Adjust shift for decryption
    if ($Decrypt) {
        $Shift = -$Shift
    }

    # Initialize the result string
    $Result = ""

    # Iterate through each character in the input text
    foreach ($char in $Text.ToCharArray()) {
        if ($char -match '[a-zA-Z]') {
            # Determine if the character is uppercase or lowercase
            $isUpper = ($char -cmatch '[A-Z]')
            $offset = if ($isUpper) { [int][char]'A' } else { [int][char]'a' }

            # Apply the shift and wrap around the alphabet
            $newChar = [char](((26 + ([int][char]$char - $offset + $Shift)) % 26) + $offset)
            $Result += $newChar
        } else {
            # Non-alphabetic characters are appended without modification
            $Result += $char
        }
    }

    return $Result
}

# Example usage
$plainText = "Hello, World!"
$shift = 3

# Encrypt
$encryptedText = Convert-CaesarCipher -Text $plainText -Shift $shift
Write-Host "Encrypted: $encryptedText"

# Decrypt
$decryptedText = Convert-CaesarCipher -Text $encryptedText -Shift $shift -Decrypt
Write-Host "Decrypted: $decryptedText"