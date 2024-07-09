allowable_gap = 50
def update_sequence_with_mac(sequences):
    A = {}  # Initialize the dictionary to store MAC prefixes as keys, with lists of sequence numbers as values
    for line in sequences.split('\n'):
        if line.strip():  # Check if the line is not empty
            mac, num_str = line.strip().split()  # Split MAC address and sequence number
            num = int(num_str)
            mac_prefix = mac.upper()[:8]  # Get the MAC address prefix

            to_replace = False  # Flag to check if the current num has replaced an element in A
            found= False
            # Use a temporary list to hold keys due to potential modification during iteration
            keys_list = list(A.keys())
            for key in keys_list:
                if mac_prefix==key:
                    found= True
                    for vale in range(0, len(A[key])):
                        if (num <= (A[key][vale] + allowable_gap)) and (num >= (A[key][vale] - allowable_gap)) :  # Compare with the last ele>
                            A[key][vale] = num  # Replace the last element with the new number
                            to_replace = True
                            break  # Stop searching once a replacement is made

                    # After checking all value and did not find close value appened
                    if not to_replace:  # If num didn't replace any element, add it as a new element with its MAC prefix
                        A[mac_prefix].append(num)  # Append the new number to the list
                        break # no need to check the rest of the list

            if not found: # mac_prefix not in A:
                A[mac_prefix] = []
                A[mac_prefix].append(num)
    return A

# Function to read data from a file and pass it to the update_sequence_with_mac function
def process_file(filename):
    with open(filename, 'r') as file:
        data = file.read()
        updated_sequence = update_sequence_with_mac(data)
        return updated_sequence

def main():
    # File contains unique MACs
    unique_mac = 'unique.txt'
    # Read the data from the file and update the sequence
    updated_sequence = process_file(unique_mac)

if __name__ == "__main__":
    main()
