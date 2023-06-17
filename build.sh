#!/bin/sh
echo "****Initializing the Terraform providers****"
terraform init
echo "Deleting files from previous builds"
rm -f package.zip
echo "Installing the Python packages [dependencies] into the package directory"
pip3 install -r requirements.txt --target ./package
echo "Copying the Python files into the package directory"
cp *.py package/
echo "Clean up caches in the package directory"
pushd package
rm -rf bin
rm -rf __pycache__
zip ../package.zip *
popd
echo "Zip the files for deployment [package.zip]"
echo "The code is ready for Lambda deployment [package.zip]"
echo "Redeploying the application code"
source ~/.bashrc && terraform apply
echo "****The function has been deployed****"