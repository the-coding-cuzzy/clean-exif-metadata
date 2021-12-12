#!/usr/bin/env sh

set -e

echo "Executing package-lambda.sh..."

home=$PWD

mkdir -p ./lambda

# Create and activate virtual environment...
python3 -m venv .env
. .env/bin/activate

# # Installing python dependencies...
pip3 install --upgrade pip
pip3 install -qr ../../lambda/requirements.txt --force-reinstall

# # Deactivate virtual environment...
deactivate

# Create deployment package...
echo "Creating deployment package..."
cd $home/.env/lib/python3.8/site-packages/
cp -r . $home/lambda

cd $home/../../lambda
cp -r . $home/lambda

cd $home/lambda
zip -qr $home/lambda.zip .

# Removing virtual environment folder...
echo "Removing virtual environment folder..."
rm -rf $home/.env

# Remove temporarily created directory
rm -rf $home/lambda

echo "Finished script execution!"
