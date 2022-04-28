#!/usr/bin/env bash
# this is an optional script to download some sample images available from Microsoft , 
# who sponsors the Megadetector project
echo "Downloading sample images from Microsoft hosted on Azure"
echo "This script Requires azcopy installed and in the path and will error without it"
mkdir -p "testphotos" && azcopy cp "https://lilablobssc.blob.core.windows.net/missouricameratraps/images/Set1/1.02-Agouti/SEQ75520?st=2020-01-01T00%3A00%3A00Z&se=2034-01-01T00%3A00%3A00Z&sp=rl&sv=2019-07-07&sr=c&sig=zf5Vb3BmlGgBKBM1ZtAZsEd1vZvD6EbN%2BNDzWddJsUI%3D" "`pwd`/testphotos" --recursive

