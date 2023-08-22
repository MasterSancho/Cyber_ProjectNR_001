# Generate an SSH key pair for secure authentication.
# This eliminates the need for using a password when connecting to the server via SSH.

# Step 1: Generate the SSH key pair locally
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
# -t specifies the type of key (RSA in this case)
# -b specifies the number of bits in the key (4096 bits for strong security)
# -C provides a comment to help identify the key

# Step 2: Copy the public key to the server for authentication
ssh-copy-id user@server_ip
# This command copies the public key to the server's authorized_keys file,
# allowing you to authenticate without a password.

# After completing these steps, you'll be able to log in to the server securely
# using your private key, enhancing the security of your SSH connections.
