#!/bin/bash

# This is a shell script to build 32-bit Linux NASM files.
# It will automatically clean up the .o file upon success.

# Check if a filename was provided
if [ -z "$1" ]; then
    echo "Usage: ./build.sh <filename.asm>"
    exit 1
fi

# Get the filename without the .asm extension
BASENAME="${1%.*}"

echo "[1] Assembling $1..."
nasm -f elf32 "$1" -o "$BASENAME.o"

# Check if assembly failed
if [ $? -ne 0 ]; then
    echo "--- ASSEMBLY FAILED ---"
    exit 1
fi

echo "[2] Linking $BASENAME.o..."
ld -m elf_i386 "$BASENAME.o" -o "$BASENAME"

# Check if linking failed
if [ $? -ne 0 ]; then
    echo "--- LINKING FAILED ---"
    exit 1
fi

# --- NEW PART ---
# If we get here, both steps succeeded.
# Time to clean up the object file.
echo "[3] Cleaning up $BASENAME.o... 🧹"
rm "$BASENAME.o"

echo "[4] Done! Executable created: $BASENAME"
