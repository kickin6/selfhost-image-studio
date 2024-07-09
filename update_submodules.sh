#!/bin/bash

git submodule update --remote --merge
git add path/to/selfhost-image path/to/selfhost-nginx path/to/Fooocus-API
git commit -m "Updated submodules to latest versions"

